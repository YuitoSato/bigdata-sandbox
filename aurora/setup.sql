
CREATE TABLE TENANTS
(
    TENANT_ID INTEGER               NOT NULL
        CONSTRAINT TENANTS_PK PRIMARY KEY,
    NAME      CHARACTER varying(30) NOT NULL
);

CREATE TABLE ACCOUNTS
(
    account_id INTEGER               NOT NULL
        CONSTRAINT ACCOUNTS_PK PRIMARY KEY,
    TENANT_ID  INTEGER               NOT NULL
        CONSTRAINT FK_ACCOUNTS_TENANTS
            REFERENCES TENANTS
            ON UPDATE RESTRICT ON DELETE RESTRICT,
    NAME       CHARACTER VARYING(30) NOT NULL
);

SELECT pg_create_logical_replication_slot('airbyte_slot', 'pgoutput');
ALTER TABLE TENANTS
    REPLICA IDENTITY DEFAULT;
ALTER TABLE ACCOUNTS
    REPLICA IDENTITY DEFAULT;
CREATE PUBLICATION AIRBYTE_PUBLICATION FOR TABLE TENANTS, ACCOUNTS;
