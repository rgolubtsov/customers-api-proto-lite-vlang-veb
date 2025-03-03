--
-- data/sql/01-create-and-populate-table-customers.sql
-- ============================================================================
-- Customers API Lite microservice prototype (V port). Version 0.2.0
-- ============================================================================
-- A daemon written in V (vlang/veb), designed and intended to be run
-- as a microservice, implementing a special Customers API prototype
-- with a smart yet simplified data scheme.
-- ============================================================================
-- (See the LICENSE file at the top of the source tree.)
--

-- $ # Usage:
-- $ # (1) Go to the "data/db/" directory.
-- $ cd data/db/
-- $
-- $ # (2) Create and populate the "customers" table with initial data.
-- $ sqlite3 customers-api-lite.db < \
-- ../sql/01-create-and-populate-table-customers.sql
-- ...

.headers   on
.mode      column
.nullvalue NULL

.tables
.print

create table customers (id   integer     not null primary key autoincrement,
                        name varchar(64) not null);

.tables
.print

pragma table_info(customers);
.print

select * from customers;

insert into customers (name) values ('Jammy Jellyfish');
insert into customers (name) values ('Noble Numbat'   );

select * from customers;

-- vim:set nu et ts=4 sw=4:
