--
-- data/sql/02-create-and-populate-table-contact_phones.sql
-- ============================================================================
-- Customers API Lite microservice prototype (V port). Version 0.0.12
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
-- $ # (2) Create and populate the "contact_phones" table with initial data.
-- $ sqlite3 customers-api-lite.db < \
-- ../sql/02-create-and-populate-table-contact_phones.sql
-- ...

.headers   on
.mode      column
.nullvalue NULL

.tables
.print

create table contact_phones (id          integer      not null primary key
                                                               autoincrement,
                             contact     varchar(15),
                             customer_id integer      references customers(id)
                                                      on delete restrict);

.tables
.print

pragma table_info(contact_phones);
.print

select * from contact_phones;

-- ----------------------------------------------------------------------------
insert into contact_phones (contact, customer_id)
                    values ('+35790A123456',   1);
insert into contact_phones (contact, customer_id)
                    values ('+35790B1234578',  1);
insert into contact_phones (contact, customer_id)
                    values ('+35760C12345890', 1);
-- ----------------------------------------------------------------------------
insert into contact_phones (contact, customer_id)
                    values ('+35760X123456',   2);
insert into contact_phones (contact, customer_id)
                    values ('+35760Y1234578',  2);
insert into contact_phones (contact, customer_id)
                    values ('+35790Z12345890', 2);
-- ----------------------------------------------------------------------------

select * from contact_phones;

-- vim:set nu et ts=4 sw=4:
