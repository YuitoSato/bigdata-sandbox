CREATE TABLE tenants
(
    tenant_id integer               NOT NULL
        constraint tenants_pk primary key,
    name      character varying(30) NOT NULL
);

CREATE TABLE accounts
(
    account_id integer               NOT NULL
        constraint accounts_pk primary key,
    tenant_id  integer               NOT NULL
        constraint fk_accounts_tenants
            references tenants
            on update restrict on delete restrict,
    name       character varying(30) NOT NULL
);

SELECT pg_create_logical_replication_slot('airbyte_slot', 'pgoutput');
ALTER TABLE tenants REPLICA IDENTITY DEFAULT;
ALTER TABLE accounts REPLICA IDENTITY DEFAULT;
CREATE PUBLICATION airbyte_publication FOR TABLE tenants, accounts;
