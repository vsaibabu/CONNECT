-- create application user
CREATE USER nhincuser IDENTIFIED BY 'nhincpass';

-- begin assigning authority
CREATE DATABASE assigningauthoritydb;

CREATE TABLE assigningauthoritydb.aa_to_home_community_mapping (
  id int(10) unsigned NOT NULL auto_increment,
  assigningauthorityid varchar(64) NOT NULL,
  homecommunityid varchar(64) NOT NULL,
  PRIMARY KEY  (id,assigningauthorityid)
);

GRANT SELECT,INSERT,UPDATE,DELETE ON assigningauthoritydb.* to nhincuser;
-- end assigning authority

-- begin auditrepo
CREATE DATABASE auditrepo;

CREATE TABLE auditrepo.auditrepository
(
    id BIGINT NOT NULL AUTO_INCREMENT,
    audit_timestamp DATETIME,
    eventId BIGINT NOT NULL,
    userId VARCHAR(100),
    participationTypeCode SMALLINT,
    participationTypeCodeRole SMALLINT,
    participationIDTypeCode VARCHAR(100),
    receiverPatientId VARCHAR(128),
    senderPatientId VARCHAR(128),
    communityId VARCHAR(255),
    messageType VARCHAR(100) NOT NULL,
    message LONGBLOB,
    PRIMARY KEY (id),
    UNIQUE UQ_eventlog_id(id)
);

GRANT SELECT,INSERT,UPDATE,DELETE ON auditrepo.* to nhincuser;
-- end auditrepo

-- begin configdb
CREATE DATABASE configdb;

-- -----------------------------------------------------
-- Table `configdb`.`domain`
-- -----------------------------------------------------

CREATE TABLE configdb.domain (
    id serial PRIMARY KEY,
    createTime TIMESTAMP, domainname VARCHAR(255),
    postmasterAddressId BIGINT,
    status INTEGER,
    updateTime TIMESTAMP
);

CREATE UNIQUE INDEX domain_name_idx ON configdb.domain (domainName);

-- -----------------------------------------------------
-- Table `configdb`.`address`
-- -----------------------------------------------------

CREATE TABLE configdb.address (
    id serial PRIMARY KEY,
    displayName varchar(100),
    eMailAddress varchar(255),
    endpoint varchar(255),
    status smallint DEFAULT 0,
    type varchar(64),
    createTime TIMESTAMP DEFAULT NOW(),
    updateTime TIMESTAMP,
    domainId bigint NOT NULL references configdb.domain(id)
);

CREATE UNIQUE INDEX address_email_idx ON configdb.address (eMailAddress(255));

-- -----------------------------------------------------
-- Table `configdb`.`anchor`
-- -----------------------------------------------------

CREATE TABLE configdb.anchor (
    id serial PRIMARY KEY,
    owner varchar(255),
    thumbprint varchar(64),
    certificateId bigint,
    createTime TIMESTAMP DEFAULT NOW(),
    certificateData mediumblob,
    validStartDate timestamp,
    validEndDate timestamp,
    forIncoming smallint DEFAULT 1,
    forOutgoing smallint DEFAULT 1,
    status smallint DEFAULT 0
);

CREATE UNIQUE INDEX anchor_owner_tprint_idx ON configdb.anchor (owner(255), thumbprint);

-- -----------------------------------------------------
-- Table `configdb`.`certificate`
-- -----------------------------------------------------

CREATE TABLE configdb.certificate (
    id serial PRIMARY KEY,
    owner varchar(255),
    thumbprint varchar(64),
    createTime TIMESTAMP DEFAULT NOW(),
    certificateData mediumblob,
    validStartDate timestamp,
    validEndDate timestamp,
    status smallint DEFAULT 0,
    PRIVATEKEY SMALLINT
);

CREATE UNIQUE INDEX certificate_owner_tprint_idx ON configdb.certificate (owner(255), thumbprint);

-- -----------------------------------------------------
-- Table `configdb`.`certpolicy`
-- -----------------------------------------------------

CREATE TABLE configdb.certpolicy (
    id serial PRIMARY KEY,
    createtime TIMESTAMP NOT NULL,
    lexicon INTEGER NOT NULL,
    data BLOB(204800) NOT NULL,
    policyName VARCHAR(255)
);

-- -----------------------------------------------------
-- Table `configdb`.`certpolicygroup`
-- -----------------------------------------------------

CREATE TABLE configdb.certpolicygroup (
    id serial PRIMARY KEY,
    createTime TIMESTAMP NOT NULL,
    policyGroupName VARCHAR(255)
);

-- -----------------------------------------------------
-- Table `configdb`.`certpolicygroupdomainreltn`
-- -----------------------------------------------------

CREATE TABLE configdb.certpolicygroupdomainreltn (
    id serial PRIMARY KEY,
    policy_group_id BIGINT NOT NULL references configdb.domain(id),
    domain_id BIGINT NOT NULL references configdb.certpolicygroup(id)
);

-- -----------------------------------------------------
-- Table `configdb`.`certpolicygroupreltn`
-- -----------------------------------------------------

CREATE TABLE configdb.certpolicygroupreltn (
    id serial PRIMARY KEY,
    incoming SMALLINT,
    outgoing SMALLINT,
    policyUse INTEGER NOT NULL,
    certPolicyId BIGINT NOT NULL references configdb.certpolicy(id),
    certPolicyGroupId BIGINT NOT NULL references configdb.certpolicygroup(id)
);

-- -----------------------------------------------------
-- Table `configdb`.`dnsrecord`
-- -----------------------------------------------------

CREATE TABLE configdb.dnsrecord (
    id serial PRIMARY KEY,
    createTime TIMESTAMP,
    data BLOB(8192),
    dclass INTEGER,
    name VARCHAR(255),
    ttl BIGINT,
    type INTEGER
);

-- -----------------------------------------------------
-- Table `configdb`.`setting`
-- -----------------------------------------------------

CREATE TABLE configdb.setting (
    id serial PRIMARY KEY,
    name VARCHAR(255),
    status INTEGER,
    createTime TIMESTAMP,
    updateTime TIMESTAMP,
    value VARCHAR(4096)
);

-- -----------------------------------------------------
-- Table `configdb`.`trustbundle`
-- -----------------------------------------------------

CREATE TABLE configdb.trustbundle (
    id serial PRIMARY KEY,
    bundleName VARCHAR(255) NOT NULL,
    bundleURL VARCHAR(255) NOT NULL,
    getCheckSum VARCHAR(255) NOT NULL,
    createTime TIMESTAMP NOT NULL,
    lastRefreshAttempt TIMESTAMP,
    lastRefreshError INTEGER,
    lastSuccessfulRefresh TIMESTAMP,
    refreshInterval INTEGER,
    signingCertificateData BLOB(4096)
);

-- -----------------------------------------------------
-- Table `configdb`.`trustbundleanchor`
-- -----------------------------------------------------

CREATE TABLE configdb.trustbundleanchor (
    id serial PRIMARY KEY,
    anchorData BLOB(4096) NOT NULL,
    thumbprint VARCHAR(255) NOT NULL,
    validEndDate TIMESTAMP NOT NULL,
    validStartDate TIMESTAMP NOT NULL,
    trustbundleId BIGINT NOT NULL references configdb.trustbundle(id)
);

-- -----------------------------------------------------
-- Table `configdb`.`trustbundledomainreltn`
-- -----------------------------------------------------

CREATE TABLE configdb.trustbundledomainreltn (
    id serial PRIMARY KEY,
    forIncoming SMALLINT,
    forOutgoing SMALLINT,
    domain_id BIGINT NOT NULL references configdb.domain (id),
    trust_bundle_id BIGINT NOT NULL references configdb.trustbundle(id)
);

-- CREATE TABLE configdb.HIBERNATE_UNIQUE_KEY (
--     NEXT_HI INTEGER
-- );

GRANT SELECT,INSERT,UPDATE,DELETE ON configdb.* to nhincuser;
-- end configdb

-- begin docrepository
CREATE DATABASE docrepository;

CREATE TABLE docrepository.document (
  documentid int(11) NOT NULL,
  DocumentUniqueId varchar(64) NOT NULL,
  DocumentTitle varchar(128) default NULL,
  authorPerson varchar(64) default NULL,
  authorInstitution varchar(64) default NULL,
  authorRole varchar(64) default NULL,
  authorSpecialty varchar(64) default NULL,
  AvailabilityStatus varchar(64) default NULL,
  ClassCode varchar(64) default NULL,
  ClassCodeScheme varchar(64) default NULL,
  ClassCodeDisplayName varchar(64) default NULL,
  ConfidentialityCode varchar(64) default NULL,
  ConfidentialityCodeScheme varchar(64) default NULL,
  ConfidentialityCodeDisplayName varchar(64) default NULL,
  CreationTime datetime default NULL COMMENT 'Date format expected: MM/dd/yyyy.HH:mm:ss',
  FormatCode varchar(64) default NULL,
  FormatCodeScheme varchar(64) default NULL,
  FormatCodeDisplayName varchar(64) default NULL,
  PatientId varchar(128) default NULL COMMENT 'Format of HL7 2.x CX',
  ServiceStartTime datetime default NULL COMMENT 'Format of YYYYMMDDHHMMSS',
  ServiceStopTime datetime default NULL COMMENT 'Format of YYYYMMDDHHMMSS',
  Status varchar(64) default NULL,
  Comments varchar(256) default NULL,
  Hash varchar(1028) default NULL COMMENT 'Might be better to derive',
  FacilityCode varchar(64) default NULL,
  FacilityCodeScheme varchar(64) default NULL,
  FacilityCodeDisplayName varchar(64) default NULL,
  IntendedRecipientPerson varchar(128) default NULL COMMENT 'Format of HL7 2.x XCN',
  IntendedRecipientOrganization varchar(128) default NULL COMMENT 'Format of HL7 2.x XON',
  LanguageCode varchar(64) default NULL,
  LegalAuthenticator varchar(128) default NULL COMMENT 'Format of HL7 2.x XCN',
  MimeType varchar(32) default NULL,
  ParentDocumentId varchar(64) default NULL,
  ParentDocumentRelationship varchar(64) default NULL,
  PracticeSetting varchar(64) default NULL,
  PracticeSettingScheme varchar(64) default NULL,
  PracticeSettingDisplayName varchar(64) default NULL,
  DocumentSize int(11) default NULL,
  SourcePatientId varchar(128) default NULL COMMENT 'Format of HL7 2.x CX',
  Pid3 varchar(128) default NULL,
  Pid5 varchar(128) default NULL,
  Pid7 varchar(128) default NULL,
  Pid8 varchar(128) default NULL,
  Pid11 varchar(128) default NULL,
  TypeCode varchar(64) default NULL,
  TypeCodeScheme varchar(64) default NULL,
  TypeCodeDisplayName varchar(64) default NULL,
  DocumentUri varchar(128) default NULL COMMENT 'May derive this value',
  RawData longblob,
  Persistent int(11) NOT NULL,
  OnDemand tinyint(1) NOT NULL default 0 COMMENT 'Indicate whether document is dynamic (true or 1) or static (false or 0).',
  NewDocumentUniqueId varchar(128) default NULL,
  NewRepositoryUniqueId varchar(128) default NULL,
  PRIMARY KEY  (documentid)
);

CREATE TABLE docrepository.eventcode (
  eventcodeid int(11) NOT NULL,
  documentid int(11) NOT NULL COMMENT 'Foreign key to document table',
  EventCode varchar(64) default NULL,
  EventCodeScheme varchar(64) default NULL,
  EventCodeDisplayName varchar(64) default NULL,
  PRIMARY KEY  (eventcodeid)
);

GRANT SELECT,INSERT,UPDATE,DELETE ON docrepository.* to nhincuser;
-- end docrepository

-- begin patientcorrelationdb
CREATE DATABASE patientcorrelationdb;

CREATE TABLE patientcorrelationdb.correlatedidentifiers (
  correlationId int(10) unsigned NOT NULL auto_increment,
  PatientAssigningAuthorityId varchar(64) NOT NULL,
  PatientId varchar(128) NOT NULL,
  CorrelatedPatientAssignAuthId varchar(64) NOT NULL,
  CorrelatedPatientId varchar(128) NOT NULL,
  CorrelationExpirationDate datetime,
  PRIMARY KEY  (correlationId)
);

CREATE TABLE patientcorrelationdb.pddeferredcorrelation (
  Id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  MessageId VARCHAR(100) NOT NULL,
  AssigningAuthorityId varchar(64) NOT NULL,
  PatientId varchar(128) NOT NULL,
  CreationTime DATETIME NOT NULL,
  PRIMARY KEY (Id)
);

GRANT SELECT,INSERT,UPDATE,DELETE ON patientcorrelationdb.* to nhincuser;
-- end patientcorrelationdb

-- begin subscription repository creation
CREATE DATABASE subscriptionrepository;

CREATE TABLE subscriptionrepository.subscription (
    id VARCHAR(128) NOT NULL COMMENT 'Database generated UUID',
    Subscriptionid VARCHAR(128) COMMENT 'Unique identifier for a CONNECT generated subscription',
    SubscribeXML LONGTEXT COMMENT 'Full subscribe message as an XML string',
    SubscriptionReferenceXML LONGTEXT COMMENT 'Full subscription reference as an XML string',
    RootTopic LONGTEXT COMMENT 'Root topic of the subscription record',
    ParentSubscriptionId VARCHAR(128) COMMENT 'Subscription id for a parent record provided for fast searching',
    ParentSubscriptionReferenceXML LONGTEXT COMMENT 'Full subscription reference for a parent record as an XML string',
    Consumer VARCHAR(128) COMMENT 'Notification consumer system',
    Producer VARCHAR(128) COMMENT 'Notification producer system',
    PatientId VARCHAR(128) COMMENT 'Local system patient identifier',
    PatientAssigningAuthority VARCHAR(128) COMMENT 'Assigning authority for the local patient identifier',
    Targets LONGTEXT COMMENT 'Full target system as an XML string',
    CreationDate DATETIME COMMENT 'Format of YYYYMMDDHHMMSS',
  PRIMARY KEY(id)
);

GRANT SELECT,INSERT,UPDATE,DELETE ON subscriptionrepository.* to nhincuser;
-- end subscription repository creation

-- begin asyncmsgs
CREATE DATABASE asyncmsgs;

CREATE TABLE IF NOT EXISTS asyncmsgs.asyncmsgrepo (
    Id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    MessageId VARCHAR(100) NOT NULL,
    CreationTime DATETIME NOT NULL,
    ResponseTime DATETIME NULL DEFAULT NULL,
    Duration BIGINT NULL DEFAULT 0,
    ServiceName VARCHAR(45) NULL DEFAULT NULL,
    Direction VARCHAR(10) NULL DEFAULT NULL,
    CommunityId VARCHAR(100) NULL DEFAULT NULL,
    Status VARCHAR(45) NULL DEFAULT NULL,
    ResponseType VARCHAR(10) NULL DEFAULT NULL,
    Reserved VARCHAR(100) NULL DEFAULT NULL,
    MsgData LONGBLOB NULL DEFAULT NULL,
    RspData LONGBLOB NULL DEFAULT NULL,
    AckData LONGBLOB NULL DEFAULT NULL,
    PRIMARY KEY (Id)
);

GRANT SELECT,INSERT,UPDATE,DELETE ON asyncmsgs.* to nhincuser;
-- end asyncmsgs

-- begin logging
CREATE DATABASE logging;

CREATE TABLE logging.log (
    dt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    context varchar(100) DEFAULT NULL,
    logLevel varchar(10) DEFAULT NULL,
    class varchar(500) DEFAULT NULL,
    message longtext
);

GRANT SELECT,INSERT,UPDATE,DELETE ON logging.* to nhincuser;
-- end logging

-- begin patientdb
CREATE DATABASE patientdb;

CREATE TABLE patientdb.patient (
  patientId BIGINT NOT NULL AUTO_INCREMENT,
  dateOfBirth DATE NULL,
  gender CHAR(2) NULL,
  ssn CHAR(9) NULL,
  PRIMARY KEY (patientId),
  UNIQUE INDEX patientId_UNIQUE (patientId ASC) )
COMMENT = 'Patient Repository';

CREATE TABLE patientdb.identifier (
  identifierId BIGINT NOT NULL AUTO_INCREMENT,
  patientId BIGINT NOT NULL,
  id VARCHAR(64) NULL,
  organizationId VARCHAR(64) NULL,
  PRIMARY KEY (identifierId),
  UNIQUE INDEX identifierrId_UNIQUE (identifierId ASC),
  INDEX fk_identifier_patient (patientId ASC),
  CONSTRAINT fk_identifier_patient
    FOREIGN KEY (patientId )
    REFERENCES patientdb.patient (patientId )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT = 'Identifier definitions';

CREATE TABLE patientdb.personname (
  personnameId BIGINT NOT NULL AUTO_INCREMENT,
  patientId BIGINT NOT NULL,
  prefix VARCHAR(64) NULL,
  firstName VARCHAR(64) NULL,
  middleName VARCHAR(64) NULL,
  lastName VARCHAR(64) NULL,
  suffix VARCHAR(64) NULL,
  PRIMARY KEY (personnameId),
  UNIQUE INDEX personnameId_UNIQUE (personnameId ASC),
  INDEX fk_personname_patient (patientId ASC),
  CONSTRAINT fk_personname_patient
    FOREIGN KEY (patientId )
    REFERENCES patientdb.patient (patientId )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT = 'Person Names';

CREATE TABLE patientdb.address (
  addressId BIGINT NOT NULL AUTO_INCREMENT,
  patientId BIGINT NOT NULL,
  street1 VARCHAR(128) NULL,
  street2 VARCHAR(128) NULL,
  city VARCHAR(128) NULL,
  state VARCHAR(128) NULL,
  postal VARCHAR(45) NULL,
  PRIMARY KEY (addressId),
  UNIQUE INDEX addressId_UNIQUE (addressId ASC),
  INDEX fk_address_patient (patientId ASC),
  CONSTRAINT fk_address_patient
    FOREIGN KEY (patientId )
    REFERENCES patientdb.patient (patientId )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT = 'Addresses';

CREATE TABLE patientdb.phonenumber (
  phonenumberId BIGINT NOT NULL AUTO_INCREMENT,
  patientId BIGINT NOT NULL,
  value VARCHAR(64) NULL,
  PRIMARY KEY (phonenumberId),
  UNIQUE INDEX phonenumberId_UNIQUE (phonenumberId ASC),
  INDEX fk_phonenumber_patient (patientId ASC),
  CONSTRAINT fk_phonenumber_patient
    FOREIGN KEY (patientId )
    REFERENCES patientdb.patient (patientId )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT = 'Phone Numbers';

GRANT SELECT,INSERT,UPDATE,DELETE ON patientdb.* to nhincuser;
-- end patientdb

-- begin transrepo

CREATE DATABASE transrepo;

CREATE TABLE transrepo.transactionrepository (
    id BIGINT NOT NULL AUTO_INCREMENT,
    transactionId VARCHAR(100) NOT NULL,
    messageId VARCHAR(100) NOT NULL,
    transactionTime TIMESTAMP NULL,
    PRIMARY KEY (id),
    INDEX messageId_idx (messageId),
    UNIQUE transID_UNIQUE (transactionId, messageId) )
COMMENT = 'Message Transaction Repository';

GRANT SELECT,INSERT,UPDATE,DELETE ON transrepo.* to nhincuser;
-- end transrepo

-- begin eventdb

CREATE DATABASE eventdb;

CREATE TABLE eventdb.event (
  id BIGINT NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description longtext,
  transactionId VARCHAR(100),
  messageId VARCHAR(100),
  eventTime TIMESTAMP,
  PRIMARY KEY (id) )
COMMENT = 'Event Logging';

GRANT SELECT,INSERT,UPDATE,DELETE ON eventdb.* to nhincuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON *.* TO 'nhincuser'@'localhost' IDENTIFIED BY 'nhincpass' WITH GRANT OPTION;
GRANT SELECT,INSERT,UPDATE,DELETE ON *.* TO 'nhincuser'@'127.0.0.1' IDENTIFIED BY 'nhincpass' WITH GRANT OPTION;
-- end eventdb

GRANT ALL PRIVILEGES ON *.* TO 'nhincuser'@'localhost' IDENTIFIED BY 'nhincpass' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'nhincuser'@'127.0.0.1' IDENTIFIED BY 'nhincpass' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'nhincuser'@'{host name}' IDENTIFIED BY 'nhincpass' WITH GRANT OPTION;
FLUSH PRIVILEGES;
