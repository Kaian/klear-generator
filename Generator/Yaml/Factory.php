<?php
class Generator_Yaml_Factory
{
    protected $_klearDirs;
    protected $_override = false;
    protected $_namespace;

    protected $_klearConfig;
    protected $_configWriter;

    protected $_tables = null;

    public function __construct($basePath, $namespace, $override = false)
    {
        $this->_klearDirs = array(
                'root' => $basePath,
                'model' => $basePath . '/model',
                'conf.d' => $basePath . '/conf.d'
        );
        $this->_namespace = $namespace;
        $this->_override = (bool)$override;


        $this->_klearConfig = new Zend_Config_Ini(APPLICATION_PATH. '/configs/klear.ini', APPLICATION_ENV);
        $this->_configWriter = new Zend_Config_Writer_Yaml();

        $this->_createDirStructure();
    }

    protected function _createDirStructure()
    {
        //If override is set, remove all existing config
        if ($this->_override) {
            if (file_exists($this->_klearDirs['root'])) {
                $this->_rrmdir($this->_klearDirs['root']);
            }
        }

        foreach ($this->_klearDirs as $dir) {
            if (!file_exists($dir)) {
                if (!mkdir($dir)) {
                    throw new Exception('Klear configuration dir could not be created in: ' . $dir);
                };
            }
        }
    }

    # recursively remove a directory
    protected function _rrmdir($dir) {
        foreach(glob($dir . '/*') as $file) {
            if(is_dir($file))
                $this->_rrmdir($file);
            else
                unlink($file);
        }
        rmdir($dir);
    }

    public function createErrorsFile()
    {
        $errorsFile = $this->_klearDirs['root'] . '/errors.yaml';
        if (!file_exists($errorsFile) || $this->_override) {
            $errorsConfig = new Generator_Yaml_ErrorsConfig();
            $this->_configWriter->write($errorsFile, $errorsConfig->getConfig());
        }
        return $this;
    }

    public function createActionsFile()
    {
        $actionsFile = $this->_klearDirs['conf.d'] . '/actions.yaml';
        if (!file_exists($actionsFile) || $this->_override) {
            copy(__DIR__ . "/klear/conf.d/actions.yaml", $actionsFile);
        }
        return $this;
    }

    public function createModelFiles()
    {
        $tables = $this->_getTables();
        foreach ($tables as $table) {
            $modelFile = $this->_klearDirs['model'] . '/' . ucfirst(Generator_Yaml_StringUtils::toCamelCase($table)) . '.yaml';
            if (!file_exists($modelFile) || $this->_override) {
                $modelConfig = new Generator_Yaml_ModelConfig($table, $this->_namespace, $this->_klearConfig);
                $this->_configWriter->write($modelFile, $modelConfig->getConfig());
            }
        }
        return $this;
    }

    public function createModelListFiles()
    {
        $entities = $this->_getEntities();
        foreach ($entities as $table) {
            $listFile = $this->_klearDirs['root'] . '/' . ucfirst(Generator_Yaml_StringUtils::toCamelCase($table)) . 'List.yaml';
            if (!file_exists($listFile) || $this->_override) {
                $listConfig = new Generator_Yaml_ListConfig($table, $this->_klearConfig);
                $this->_configWriter->write($listFile, $listConfig->getConfig());
                $contents = "#include conf.d/mapperList.yaml\n";
                $contents .= "#include conf.d/actions.yaml\n\n";
                $contents .= file_get_contents($listFile);
                file_put_contents($listFile, $contents);
            }
        }
        return $this;
    }

    public function createMainConfigFile()
    {
        $mainConfigFile = $this->_klearDirs['root'] . '/klear.yaml';
        if (!file_exists($mainConfigFile) || $this->_override) {
            $mainConfig = new Generator_Yaml_MainConfig($this->_getEntities());
            $this->_configWriter->write($mainConfigFile, $mainConfig->getConfig());
        }
    }

    protected function _getEntities()
    {
        $entities = array();
        $tables = $this->_getTables();
        foreach ($tables as $table)
        {
            $tableComment = Generator_Db::tableComment($table);
            if (stristr($tableComment, '[entity]')) {
                $entities[] = $table;
            }
        }

        return $entities;
    }

    public function createMappersListFile()
    {
        /** Generate mapper list file **/
        $mappersFile = $this->_klearDirs['conf.d'] . '/mapperList.yaml';
        if (!file_exists($mappersFile) || $this->_override) {
            $mappersConfig = new Generator_Yaml_MappersFile($this->_getTables(), $this->_namespace);
            $this->_configWriter->write($mappersFile, $mappersConfig->getConfig());
        }
        return $this;
    }

    protected function _getTables()
    {
        if (!is_null($this->_tables)) {
            return $this->_tables;
        }

        $dbAdapter = Zend_Db_Table::getDefaultAdapter();
        $this->_tables = $dbAdapter->listTables();
        return $this->_tables;
    }

    public function createAllFiles()
    {
        $this->createErrorsFile();
        $this->createMappersListFile();
        $this->createActionsFile();
        $this->createModelFiles();
        $this->createModelListFiles();
        $this->createMainConfigFile();
    }
}