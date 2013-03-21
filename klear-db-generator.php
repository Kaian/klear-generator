#!/usr/bin/php
<?php
include_once(__DIR__ . DIRECTORY_SEPARATOR . 'bootstrap.php');

define('VERSION', '0.1');
define('AUTHOR',  'Alayn Gortazar <alayn@irontec.com>');

try {
    $opts = new Zend_Console_Getopt(
        array(
            'application|a=s' => 'Zend Framework APPLICATION_PATH',
            'generate-delta|d=s' => 'Generate Delta instead of modifying database'
        )
    );
    $opts->parse();

    if (!$opts->getOption('application')) {
        throw new Zend_Console_Getopt_Exception('Parse error', $opts->getUsageMessage());
    }

    $deltaWriter = null;
    if ($opts->getOption('generate-delta')) {
        $deltaPath = realpath($opts->getOption('generate-delta'));
        $deltaWriter = new Generator_Db_FakeAdapter($deltaPath);
    }

    define('APPLICATION_PATH', realpath($opts->getOption('application')));

    if (!file_exists(APPLICATION_PATH . '/configs/application.ini')) {
        throw new Exception('application.ini not found');
    }

    if (!file_exists(APPLICATION_PATH . '/configs/klear.ini')) {
        throw new Exception('klear.ini not found, should exist on application (config)  dir');
    }

    $klearConfig = new Zend_Config_Ini(APPLICATION_PATH . '/configs/klear.ini', APPLICATION_ENV);

    if (isset($klearConfig->klear->languages)) {
        $application = new Zend_Application(APPLICATION_ENV, APPLICATION_PATH . '/configs/application.ini');
        $application->bootstrap('db');

        /** Generate Model Configuration Files **/
        $tables = Zend_Db_Table::getDefaultAdapter()->listTables();
        foreach ($tables as $table) {
            $table = new Generator_Db_Table($table, $klearConfig, $deltaWriter);
            $table->generateAllFields();
        }
    }

} catch (Zend_Console_Getopt_Exception $e) {
    echo $e->getUsageMessage() .  "\n";
    echo $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "Error: ";
    echo $e->getMessage() . "\n";
    exit(1);
}
