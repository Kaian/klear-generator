<?='<?php'?>
<?php
$namespace = !empty($this->_namespace) ? $this->_namespace . "\\" : "";
?>

/**
 * Application Model
 *
 * @package <?=$namespace?>Model\Raw
 * @subpackage Model
 * @author <?=$this->_author."\n"?>
 * @copyright <?=$this->_copyright."\n"?>
 * @license <?=$this->_license."\n"?>
 */

/**
 * Abstract class that is extended by all base models
 *
 * @package <?=$namespace?>Model\Raw  - <?=$this->getTableName();?>
 * @subpackage Model
 * @author <?=$this->_author."\n"?>
 */

namespace <?=$namespace?>Model\Raw;

abstract class ModelAbstract implements \IteratorAggregate
{
    /**
     * Mapper associated with this model instance
     *
     * @var <?=$namespace?>Model\ModelAbstract
     */
    protected $_mapper;

    /**
    * Default values for not null fields
    * @var array
    */
    protected $_defaultValues = array();

    /**
     * Validator associated with this model instance
     *
     * @var <?=$namespace?>Model\ModelValidatorAbstract
     */
    protected $_validator;

<?php if (! empty($this->_loggerName)):?>
    /**
     * $_logger - Zend_Log object
     *
     * @var Zend_Log
     */
    protected $_logger;

<?php endif; ?>
    /**
     * Associative array of columns for this model
     *
     * @var array
     */
    protected $_columnsList;

    /**
     * Associative array of columns for this model
     *
     * @var array
     */
    protected $_multiLangColumnsList;

    /**
     * Associative array of multilang columns for this model
     *
     * @var array
     */
    protected $_availableLangs = array();

    /***
     * Log changes switcher
     */
    protected $_logChanges = true;

    /***
     * Changed attributes
     */
    protected $_changeLog = array();

    /**
     * Associative array of parent relationships for this model
     *
     * @var array
     */
    protected $_parentList;

    /**
     * Associative array of dependent relationships for this model
     *
     * @var array
     */
    protected $_dependentList;

    /**
     * Orphan elements to remove on save()
     */
    protected $_orphans  = array();

    /**
     * Sql triggers
     *
     * @var bool
     */
    protected $_onDeleteCascade = array();
    protected $_onDeleteSetNull = array();

    /**
     * Default language for multilang field setters/getters
     */
    protected $_defaultUserLanguage = '';

    /**
     * Initializes common functionality in Model classes
     */
    protected function init()
    {
<?php if (! empty($this->_loggerName)):?>
        $this->_logger = \Zend_Registry::get('<?=$this->_loggerName?>');
<?php endif; ?>

    }

    public function sanitize ()
    {
        foreach ($this->_defaultValues as $fld => $val) {

            if (in_array($fld, $this->_columnsList) and is_null($this->{'_' . $fld})) {

                $this->{'_' . $fld} = $val;
            }
        }

        return $this;
    }

    public function __construct()
    {
        $availableLangs = $this->getAvailableLangs();

        if (count($availableLangs) > 0) {

            $bootstrap = \Zend_Controller_Front::getInstance()->getParam('bootstrap');

            if (is_null($bootstrap)) {

                $conf = new \Zend_Config_Ini(APPLICATION_PATH . '/configs/application.ini',APPLICATION_ENV);
                $conf = (Object) $conf->toArray();

            } else {

                $conf = (Object) $bootstrap->getOptions();
            }

            if (isset($conf->defaultLanguageZendRegistryKey)) {

                if (\Zend_Registry::isRegistered($conf->defaultLanguageZendRegistryKey)) {

                    $this->_defaultUserLanguage = \Zend_Registry::get($conf->defaultLanguageZendRegistryKey);
                }

            } else {

                    $this->_defaultUserLanguage = $availableLangs[0];
            }
        }
    }
    
    protected function _getCurrentLanguage($language = null)
    {
        if ($language) {
            if (!in_array($language, $this->getAvailableLangs())) {
                throw new \Exception($language . " is not an available language");
            }
            return $language;
        }
        
        return $this->getDefaultUserLanguage();
    }
    
    public function initChangeLog()
    {
        $this->_logChanges = true;
        return $this;
    }

    public function stopChangeLog()
    {
        $this->_logChanges = false;
        return $this;
    }

    public function hasChange ($field = '')
    {
        if (empty($field)) {

            if ( !empty($this->_changeLog) ) {

                return true;
            }

        } else {

            if ( in_array($field, $this->_changeLog) ) {

                return true;

            } else if ( in_array(lcfirst($field), $this->_changeLog) ) {

                return true;
            }
        }

        return false;
    }

    public function fetchChangelog()
    {
        return $this->_changeLog;
    }

    public function resetChangeLog()
    {
        $this->_changeLog = array();
        return $this;
    }

    protected final function _logChange($field)
    {
        $this->_changeLog[] = $field;
    }

    protected function getDefaultUserLanguage()
    {
        return $this->_defaultUserLanguage;
    }

    /**
     * Set the list of columns associated with this model
     *
     * @param array $data
     * @return <?=$namespace?>Model\ModelAbstract
     */
    public function setColumnsList($data)
    {
        $this->_columnsList = $data;
        return $this;
    }

    /**
     * Returns columns list array
     *
     * @return array
     */
    public function getColumnsList()
    {
        return $this->_columnsList;
    }

    /**
     * Set the list of columns associated with this model
     *
     * @param array $data
     * @return <?=$namespace?>Model\ModelAbstract
     */
    public function setMultiLangColumnsList($data)
    {
        $this->_multiLangColumnsList = $data;
        return $this;
    }

    /**
     * Returns columns list array
     *
     * @return array
     */
    public function getMultiLangColumnsList()
    {
        return $this->_multiLangColumnsList;
    }

    /**
     * Returns language list array
     *
     * @param array
     * @return <?=$namespace?>Model\ModelAbstract
     */
    public function setAvailableLangs($langs)
    {
        $this->_availableLangs = $langs;
        return $this;
    }

    /**
     * Returns columns list array
     *
     * @return array
     */
    public function getAvailableLangs()
    {
        return $this->_availableLangs;
    }

    /**
     * Set the list of relationships associated with this model
     *
     * @param array $data
     * @return <?=$namespace?>Model\ModelAbstract
     */
    public function setParentList($data)
    {
        $this->_parentList = $data;
        return $this;
    }

    /**
     * Returns relationship list array
     *
     * @return array
     */
    public function getParentList()
    {
        return $this->_parentList;
    }

    /**
     * Set the list of relationships associated with this model
     *
     * @param array $data
     * @return <?=$namespace?>Model\ModelAbstract
     */
    public function setDependentList($data)
    {
        $this->_dependentList = $data;
        return $this;
    }

    /**
     * Returns relationship list array
     *
     * @return array
     */
    public function getDependentList()
    {
        return $this->_dependentList;
    }

    /**
     * Get orphan elements
     */
    public function getOrphans()
    {
        return $this->_orphans;
    }

    public function resetOrphans()
    {
        $this->_orphans = array();
        return $this;
    }

    /*
     * Set the list of relationships to delete when this object is erased
     *
     * @param array $data
     * @return <?=$namespace?>Model\ModelAbstract
     */
    public function setOnDeleteCascadeRelationships($data)
    {
        $this->_onDeleteCascade = $data;
        return $this;
    }

    /**
     * Return relationships to delete when this object is erased
     *
     * @param array $data
     * @return <?=$namespace?>Model\ModelAbstract
     */
    public function getOnDeleteCascadeRelationships()
    {
        return $this->_onDeleteCascade;
    }

    /*
     * Set the list of relationships to delete when this object is erased
     *
     * @param array $data
     * @return <?=$namespace?>Model\ModelAbstract
     */
    public function setOnDeleteSetNullRelationships($data)
    {
        $this->_onDeleteSetNull = $data;
        return $this;
    }

    /**
     * Return relationships to delete when this object is erased
     *
     * @param array $data
     * @return <?=$namespace?>Model\ModelAbstract
     */
    public function getOnDeleteSetNullRelationships()
    {
        return $this->_onDeleteSetNull;
    }

    /**
     * Returns the mapper associated with this model
     *
     * @return <?=$namespace?>Model\Mapper\MapperAbstract
     */
    public abstract function getMapper();

    /**
     * Sets the mapper class
     *
     * @param <?=$namespace?>Model\Mapper\MapperAbstract $mapper
     * @return <?=$namespace?>Model\ModelAbstract
     */
    public function setMapper($mapper)
    {
        $this->_mapper = $mapper;
        return $this;
    }

    public abstract function getValidator ();

    public function setValidator($validator)
    {
        $this->_validator = $validator;
        return $this;
    }

    /**
     * Converts database column name to php setter/getter function name
     * @param string $column
     */
    public function columnNameToVar($column)
    {
        if (! isset($this->_columnsList[$column])) {
<?php if (! empty($this->_loggerName)):?>
            $this->_logger->log("Column name to variable conversion failed for '$column' in columnNameToVar for " . get_class($this), \Zend_Log::ERR);
<?php endif; ?>
            throw new \Exception("column '$column' not found!");
        }

        return $this->_columnsList[$column];
    }

    /**
     * Fetch database constraint name from column name
     * @param string $column
     */
    public function varNameToConstraint($column)
    {
        foreach ($this->_parentList as $constraint => $values) {

            if ($values['property'] == $column) {

                return $constraint;
            }
        }

        foreach ($this->_dependentList as $constraint => $values) {

            if ($values['property'] == $column) {

                return $constraint;
            }
        }

        if (! isset($this->_columnsList[$column])) {
            throw new \Exception("No contraint found for column '$column'!");
        }
    }

    /**
     * Fetch database column name from constraint
     * @param string $column
     */
    public function constraintToVarName($constraint)
    {
        if (isset($this->_parentList[$constraint])) {

            return $this->_parentList[$constraint]['property'];
        }

        if (isset($this->_dependentList[$constraint])) {

            return $this->_dependentList[$constraint]['property'];
        }

        throw new \Exception("Contraint '$constraint' not found!");
    }

    /**
     * Converts database column name to PHP setter/getter function name
     * @param string $column
     */
    public function varNameToColumn($thevar)
    {
        foreach ($this->_columnsList as $column => $var) {
            if ($var == $thevar or $var == lcfirst($thevar)) {
                return $column;
            }
        }

        return null;
    }

    /**
     * Recognize methods for Belongs-To cases:
     * <code>findBy&lt;field&gt;()</code>
     * <code>findOneBy&lt;field&gt;()</code>
     * <code>load&lt;relationship&gt;()</code>
     *
     * @param string $method
     * @throws Exception if method does not exist
     * @param array $args
     */
    public function __call($method, array $args)
    {
        $matches = array();
        $result = null;

        if (preg_match('/^find(One)?By(\w+)?$/', $method, $matches)) {
            $methods = get_class_methods($this);
            $check = 'set' . $matches[2];

            $fieldName = $this->varNameToColumn($matches[2]);

            if (! in_array($check, $methods)) {
<?php if (! empty($this->_loggerName)):?>
                $this->_logger->log("Invalid field '{$matches[2]}' requested in call for $method in " . get_class($this), \Zend_Log::ERR);
<?php endif; ?>
                throw new \Exception(
                    "Invalid field {$matches[2]} requested for table"
                );
            }

            if ($matches[1] != '') {
                $result = $this->getMapper()->findOneByField($fieldName, $args[0],
                                                           $this);
            } else {
                $result = $this->getMapper()->findByField($fieldName, $args[0],
                                                        $this);
            }

            return $result;
        } elseif (preg_match('/load(\w+)/', $method, $matches)) {
            $result = $this->getMapper()->loadRelated($matches[1], $this);

            return $result;
        }

<?php if (! empty($this->_loggerName)):?>
        $this->_logger->log("Unrecoginized method requested in call for '$method' in " . get_class($this), \Zend_Log::ERR);
<?php endif; ?>
        throw new \Exception("Unrecognized method '$method()'");
    }

    /**
     *  __set() is run when writing data to inaccessible properties overloading
     *  it to support setting columns.
     *
     * Example:
     * <code>class->column_name='foo'</code> or <code>class->ColumnName='foo'</code>
     *  will execute the function <code>class->setColumnName('foo')</code>
     *
     * @param string $name
     * @param mixed $value
     * @throws Exception if the property/column does not exist
     */
    public function __set($name, $value)
    {
        $name = $this->columnNameToVar($name);

        $method = 'set' . ucfirst($name);

        if (('mapper' == $name) || ! method_exists($this, $method)) {
<?php if (! empty($this->_loggerName)):?>
            $this->_logger->log("Unable to find setter for '$name' in " . get_class($this), \Zend_Log::ERR);
<?php endif; ?>
            throw new \Exception("name:$name value:$value - Invalid property");
        }

        $this->$method($value);
    }

    /**
     * __get() is utilized for reading data from inaccessible properties
     * overloading it to support getting columns value.
     *
     * Example:
     * <code>$foo=class->column_name</code> or <code>$foo=class->ColumnName</code>
     * will execute the function <code>$foo=class->getColumnName()</code>
     *
     * @param string $name
     * @param mixed $value
     * @throws Exception if the property/column does not exist
     * @return mixed
     */
    public function __get($name)
    {
        $method = 'get' . ucfirst($name);

        if (('mapper' == $name) || ! method_exists($this, $method)) {
            $name = $this->columnNameToVar($name);
            $method = 'get' . ucfirst($name);
            if (('mapper' == $name) || ! method_exists($this, $method)) {
<?php if (! empty($this->_loggerName)):?>
                    $this->_logger->log("Unable to find getter for '$name' in " . get_class($this), \Zend_Log::ERR);
<?php endif; ?>
                    throw new \Exception("name:$name  - Invalid property");
            }
        }

        return $this->$method();
    }

    /**
     * Array of options/values to be set for this model. Options without a
     * matching method are ignored.
     *
     * @param array $options
     * @return <?=$namespace?>Model\ModelAbstract
     */
    public function setOptions(array $options)
    {
        $methods = get_class_methods($this);
        foreach ($options as $key => $value) {

            $key = preg_replace_callback('/_(.)/', function ($matches) {
                           return ucfirst($matches[1]);
                   }, $key);

            $method = 'set' . ucfirst($key);

            if (in_array($method, $methods)) {
                $this->$method($value);
            }
        }

        return $this;
    }

    /**
     * Returns the primary key column name
     *
     * @see <?=$namespace?>Mapper\DbTable\TableAbstract::getPrimaryKeyName()
     * @return string|array The name or array of names which form the primary key
     */
    public function getPrimaryKeyName()
    {
        return $this->getMapper()->getDbTable()->getPrimaryKeyName();
    }

    /**
     * Returns an associative array of column-value pairings if the primary key
     * is an array of values, or the value of the primary key if not
     *
     * @return any|array
     */
    public function getPrimaryKey()
    {
        $primary_key = $this->getPrimaryKeyName();

        if (is_array($primary_key)) {
            $result = array();
            foreach ($primary_key as $key) {
                $result[$key] = $this->$key;
            }

            return $result;

        } else {
            return $this->$primary_key;
        }

    }

    /**
     * Returns an array, keys are the field names.
     *
     * @see <?=$namespace?>Model\Mapper\MapperAbstract::toArray()
     * @return array
     */
    public function toArray()
    {
        return $this->getMapper()->toArray($this);
    }

    /**
     * Saves current row
     *
     * @see <?=$namespace?>Model\Mapper\MapperAbstract::save()
     * @return boolean If the save was sucessful
     */
    public function save()
    {
        return $this->getMapper()->save($this);
    }

    /**
     * Saves current and dependant rows
     *
     * @see <?=$namespace?>Model\Mapper\MapperAbstract::saveRecursive()
     * @param boolean $useTransaction
     * @return boolean If the save was sucessful
     */
    public function saveRecursive($useTransaction = true)
    {
        return $this->getMapper()->saveRecursive($this, $useTransaction);
    }

    /**
     * Checks if current object values make sense
     *
     * @return boolean
     */
    public function isValid()
    {
        return $this->getValidator()->isValid($this->toArray());
    }

    /**
     * Deletes current loaded row
     *
     * @return int
     */
    public function delete()
    {
        return $this->getMapper()->delete($this);
    }

    /**
     * Serializa los atributos y Setea los mappers a null
     */
    public function __sleep()
    {
        $this->setMapper(null);
        $vars = get_object_vars($this);

        $attrs = array();

        $parentClass = get_parent_class($this);

        //Filter private properties
        foreach (array_keys($vars) as $val) {

            if (! property_exists($parentClass, $val)) {

                continue;
            }

            $attrs[] = $val;
        }

        return $attrs;
    }

    public function getColumnForParentTable($parentTable, $propertyName)
    {
        $parents = $this->getParentList();

        foreach ($parents as $_fk => $parentData) {

            if ($parentData['table_name'] == $parentTable && $propertyName == $parentData['property']) {

                return $this->columnNameToVar(
                            $this->getMapper()->getDbTable()->getReferenceMap($_fk)
                       );
                break;
            }
        }

        return false;
    }

    public function getFileObjects()
    {
        return array();
    }

    public function getIterator()
    {
        return new \ArrayIterator($this->_columnsList);
    }
}