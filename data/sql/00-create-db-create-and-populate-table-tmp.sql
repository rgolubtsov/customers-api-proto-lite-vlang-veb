--
-- data/sql/00-create-db-create-and-populate-table-tmp.sql
-- ============================================================================
-- Customers API Lite microservice prototype (V port). Version 0.1.1
-- ============================================================================
-- A daemon written in V (vlang/veb), designed and intended to be run
-- as a microservice, implementing a special Customers API prototype
-- with a smart yet simplified data scheme.
-- ============================================================================
-- (See the LICENSE file at the top of the source tree.)
--

-- $ # Go to the "data/db/" directory.
-- $ cd data/db/
-- $
-- $ # ------------------------------------------------------------------------
-- $ # Create the "customers-api-lite.db" database and create the "tmp" table.
-- $ sqlite3 customers-api-lite.db
-- SQLite version 3.45.1 2024-01-30 16:01:20
-- Enter ".help" for usage hints.
-- sqlite>
-- sqlite> .headers on
-- sqlite> .mode    column
-- sqlite>
-- sqlite> create table tmp (id    integer   primary key autoincrement,
--                           key   character varying(64) not null,
--                           value character varying(2048));
-- sqlite>
-- sqlite> .tables
-- tmp
-- sqlite>
-- sqlite> pragma table_info(tmp);
-- cid  name   type                     notnull  dflt_value  pk
-- ---  -----  -----------------------  -------  ----------  --
-- 0    id     INTEGER                  0                    1
-- 1    key    character varying(64)    1                    0
-- 2    value  character varying(2048)  0                    0
-- sqlite>
-- sqlite> .quit -- Or simply <Ctrl-D>.
-- $
-- $ # ------------------------------------------------------------------------
-- $ # Populate the "tmp" table with a single record and display its contents.
-- $ sqlite3 customers-api-lite.db \
-- < ../sql/00-create-db-create-and-populate-table-tmp.sql
-- tmp
--
-- id  key                   value
-- --  --------------------  -------------------------------
-- 1   db.location.relative  ./data/db/customers-api-lite.db

.headers on
.mode    column

.tables
.print

insert into tmp (key, value)
         values ('db.location.relative', './data/db/customers-api-lite.db');

select * from tmp;

-- vim:set nu et ts=4 sw=4:
