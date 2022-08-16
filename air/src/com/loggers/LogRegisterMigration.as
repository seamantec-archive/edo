/**
 * Created by pepusz on 2014.03.28..
 */
package com.loggers {
public class LogRegisterMigration {
    public var version:String;
    public var sql:String;


    public function LogRegisterMigration(version:String, sql:String) {
        this.version = version;
        this.sql = sql;
    }
}
}
