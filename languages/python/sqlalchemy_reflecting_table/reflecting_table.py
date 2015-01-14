__author__ = 'Aiden'

import sqlalchemy
from sqlalchemy import *
from sqlalchemy.schema import *
from sqlalchemy.engine import reflection
from sqlalchemy.orm import *


class TableSchemeExtractor(object):
    def __init__(self):
        self.initialize()

    def initialize(self):
        self.__connection_param = {
          'host': "127.0.01",
          'port': "3306",
          'user': "id",
          'password': "pw",
          'database': "db"
        }

        self.__sa_engine = create_engine("mysql://%(user)s:%(password)s@%(host)s:%(port)s/%(database)s?charset=utf8" % self.__connection_param, pool_recycle=3600)
        self.__sa_metadata = MetaData()
        self.__sa_metadata.bind = self.__sa_engine

    def get_table_names(self, scheme_name):
        inspector = reflection.Inspector.from_engine(self.__sa_engine)

        if scheme_name not in inspector.get_schema_names():
            print "%s does not exist" % scheme_name
            return []

        return inspector.get_table_names(scheme_name)

    def generate_all_dll(self, scheme_name):
        inspector = reflection.Inspector.from_engine(self.__sa_engine)

        if scheme_name not in inspector.get_schema_names():
            print "%s does not exist" % scheme_name
            return

        for table_name in inspector.get_table_names(scheme_name):
            print table_name
            table = Table(table_name, self.__sa_metadata, autoload=True, autoload_with=self.__sa_engine)
            print "  columns: %s" % table.columns
            print "  primary_key: %s" % table.primary_key
            print "  indexes: %s" % table.indexes
            open("./output/%s.%s.ddl.sql" % (scheme_name, table_name), "w").write(unicode(CreateTable(table).compile(self.__sa_engine)))


if __name__ == '__main__':
    table_scheme_extractor = TableSchemeExtractor()
    table_scheme_extractor.get_table_names('DB')
    table_scheme_extractor.generate_all_dll('DB')
