USE essentialmode;

CREATE TABLE IF NOT EXISTS `crypto_wallets`(
	`address` varchar(255) NOT NULL,
	
	`btc`FLOAT(20) DEFAULT 0,
	`eth`FLOAT(20) DEFAULT 0 ,
	`ada`FLOAT(20) DEFAULT 0 ,

	`pin` VARCHAR(50) ,
	`secret` VARCHAR(300) ,
	`userId` VARCHAR(50) ,
	PRIMARY KEY (`address`)
)ENGINE = InnoDB DEFAULT CHARSET = UTF8;


CREATE TABLE IF NOT EXISTS `crypto_coins`(
	`id` varchar(10) NOT NULL,
	`symbol` VARCHAR(20) NOT NULL,
	`price` FLOAT(20) DEFAULT NULL,
	PRIMARY KEY (`id`)
)ENGINE = InnoDB DEFAULT CHARSET = UTF8;


create table if not EXISTS `crypto_addon_warehouses`(
	`id` VARCHAR(10) NOT NULL,
	`label` VARCHAR(10) NOT NULL,
	`price` FLOAT(10) NOT NULL,
	`entrance_pos` VARCHAR(50) NOT NULL,
	`inside_pos` VARCHAR(50) NOT NULL,
	`exit_pos` VARCHAR(50) NOT NULL,
	PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = UTF8;

create table if not EXISTS `crypto_transaction_types`(
	`type` VARCHAR(10) NOT NULL,
	PRIMARY KEY (`type`)
) ENGINE = InnoDB DEFAULT CHARSET = UTF8;

create table if not EXISTS `crypto_transactions`(
	`id` INT NOT NULL AUTO_INCREMENT,
	`fromWallet` VARCHAR(255) NOT NULL,
	`toWallet` VARCHAR(255) NOT NULL,
	`currencyAmount` float(50) NOT NULL,
	`coinAmount` float(50) NOT NULL,
	`coin` VARCHAR(50) NOT NULL,
	`type` VARCHAR(255) NOT NULL,
	`dateTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	FOREIGN KEY (fromWallet) REFERENCES crypto_wallets(address),
	FOREIGN KEY (toWallet) REFERENCES crypto_wallets(address),
	FOREIGN KEY (type) REFERENCES crypto_transaction_types(type),
	FOREIGN KEY (coin) REFERENCES crypto_coins(id)

) ENGINE = InnoDB DEFAULT CHARSET = UTF8;



INSERT INTO `crypto_wallets`(address) VALUES('BrokerWallet');

INSERT INTO `crypto_transaction_types`(type) VALUES('BUY');
INSERT INTO `crypto_transaction_types`(type) VALUES('SELL');
INSERT INTO `crypto_transaction_types`(type) VALUES('TRANSFER');