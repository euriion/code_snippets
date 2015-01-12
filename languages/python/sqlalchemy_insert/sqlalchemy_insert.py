
# default
engine = create_engine('mysql://scott:tiger@localhost/foo')

# mysql-python
engine = create_engine('mysql+mysqldb://scott:tiger@localhost/foo')

# MySQL-connector-python
engine = create_engine('mysql+mysqlconnector://scott:tiger@localhost/foo')

# OurSQL
engine = create_engine('mysql+oursql://scott:tiger@localhost/foo')


engine = create_engine('postgresql://scott:tiger@localhost:5432/mydatabase')
# engine = create_engine("mysql+mysqlconnector://....
meta = MetaData()
meta.bind = engine
My table layout looks like this - together with two currently unused columns (irrelevant1/2):

MyTabe = Table('MyTable', meta,
Column('id', Integer, primary_key=True), 
Column('color', Text),
Column('irrelevant1', Text)
Column('irrelevant2', Text))

MyTable.__table__.insert().execute([{'color': 'blue'}, 
                                    {'color': 'red'}, 
                                    {'color': 'green'}])

or

conn.execute(MyTable.insert(), [{'color': 'blue'}, 
                                {'color': 'red'}, 
                                {'color': 'green'}])

[{'color': value} for value in colors]


import sqlalchemy


# default
sa_engine = create_engine('mysql://root:widerplanet@localhost/CT')
sa_meta = MetaData()
sa_meta.bind = sa_engine

table_daily_wellformed_locref_by_domain = Table('daily_wellformed_locref_by_domain', sa_meta,
  Column('dt', String(8), primary_key=True),
  Column('top_private_domain', String(100)),
  Column('domain', , String(1000)),
  Column('request_count', Integer ),
  Column('total_loc', Integer ),
  Column('wellformed_loc', Integer ),
  Column('total_ref', Integer ),
  Column('wellformed_ref', Integer )
)
