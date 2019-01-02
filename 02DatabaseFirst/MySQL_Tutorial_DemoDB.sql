DROP DATABASE IF EXISTS `tutorial_demo`;

CREATE DATABASE `tutorial_demo`;

SET @@SESSION.sql_mode = '';

DROP USER 'tutorial_demo'@'%';

FLUSH PRIVILEGES;

CREATE USER 'tutorial_demo'@'%' IDENTIFIED BY 'Password1';

FLUSH PRIVILEGES;

DROP USER 'tutorial_demo'@'localhost';

FLUSH PRIVILEGES;

CREATE USER 'tutorial_demo'@'localhost' IDENTIFIED BY 'Password1';

FLUSH PRIVILEGES;

GRANT ALL PRIVILEGES ON `tutorial_demo`.* to 'tutorial_demo'@'%';
GRANT ALL PRIVILEGES ON `tutorial_demo`.* to 'tutorial_demo'@'localhost';
GRANT SELECT ON mysql.proc TO 'tutorial_demo'@'%';
GRANT SELECT ON mysql.proc TO 'tutorial_demo'@'localhost';
GRANT SHOW VIEW ON `tutorial_demo`.* TO 'tutorial_demo'@'%';
GRANT SHOW VIEW ON `tutorial_demo`.* TO 'tutorial_demo'@'localhost';

FLUSH PRIVILEGES;

set FOREIGN_KEY_CHECKS = 0;
drop table if exists `tutorial_demo`.LineItem;
set FOREIGN_KEY_CHECKS = 1;
set FOREIGN_KEY_CHECKS = 0;
drop table if exists `tutorial_demo`.PurchaseOrder;
set FOREIGN_KEY_CHECKS = 1;
set FOREIGN_KEY_CHECKS = 0;
drop table if exists `tutorial_demo`.customer;
set FOREIGN_KEY_CHECKS = 0;
set FOREIGN_KEY_CHECKS = 0;
drop table if exists `tutorial_demo`.employee;
set FOREIGN_KEY_CHECKS = 1;
drop table if exists `tutorial_demo`.employee_picture;
drop table if exists `tutorial_demo`.`meta-table`;

create table `tutorial_demo`.`meta-table` (
  `id` int auto_increment primary key
 ,`description` varchar(100)
 ,`an_int` int
 ,`meta-href` int
 ,`meta-checksum` int
 ,`meta-action` int
);

set FOREIGN_KEY_CHECKS = 0;
drop table if exists `tutorial_demo`.product;
set FOREIGN_KEY_CHECKS = 1;

set FOREIGN_KEY_CHECKS = 0;
drop table if exists `tutorial_demo`.purchaseorder_audit;
set FOREIGN_KEY_CHECKS = 1;

drop table if exists `tutorial_demo`.LineItemJoinProduct;
drop view if exists `tutorial_demo`.customers_owing;
drop table if exists `tutorial_demo`.employee_with_picture;
drop view if exists `tutorial_demo`.v_LineItem;
drop procedure if exists `tutorial_demo`.get_employee;
drop function if exists `tutorial_demo`.`REVERSE`;


create table `tutorial_demo`.LineItem (
  lineitem_id bigint AUTO_INCREMENT primary key
 ,product_number bigint NOT NULL
 ,order_number bigint NOT NULL
 ,qty_ordered int NOT NULL
 ,product_price decimal(19,4)
 ,amount decimal(19,4)
)
ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT = 1000;

create table `tutorial_demo`.PurchaseOrder (
  order_number bigint AUTO_INCREMENT primary key
 ,amount_total decimal(19,4)
 ,paid bit(1) DEFAULT FALSE NOT NULL
 ,notes varchar(1000)
 ,customer_name varchar(50) NOT NULL
 ,salesrep_id bigint
)
ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT = 1000;

create table `tutorial_demo`.customer (
  name varchar(50) primary key
 ,balance decimal(19,4)
 ,credit_limit decimal(19,4) NOT NULL
 ,comments varchar(200)
)
ENGINE=InnoDB DEFAULT CHARSET=latin1;

create table `tutorial_demo`.employee (
  employee_id bigint AUTO_INCREMENT primary key
 ,login varchar(15) NOT NULL UNIQUE
 ,name varchar(30) not null
)
ENGINE=InnoDB DEFAULT CHARSET=latin1;

create table `tutorial_demo`.employee_picture (
  employee_id bigint primary key
 ,icon varbinary(6000)
 ,picture longblob
 ,voice mediumblob
 ,resume longtext
)
ENGINE=InnoDB DEFAULT CHARSET=latin1;

create table `tutorial_demo`.product (
  product_number bigint AUTO_INCREMENT primary key
 ,name varchar(50) NOT NULL UNIQUE
 ,price decimal(19,4) NOT NULL
 ,icon blob
 ,full_image mediumblob
)
ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT = 1000;

create table `tutorial_demo`.purchaseorder_audit (
  audit_number bigint AUTO_INCREMENT primary key
 ,order_number bigint
 ,amount_total decimal(19,4)
 ,paid bit(1)
 ,notes varchar(1000)
 ,audit_time datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
 ,customer_name varchar(50) NOT NULL
)
ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT = 1000;

create view `tutorial_demo`.LineItemJoinProduct
 as
select l.lineitem_id  LineItemId
      ,l.product_number ProductNumber
      ,l.order_number OrderNumber
      ,l.qty_ordered QuantityOrdered
      ,l.product_price ProductPriceCopy
      ,p.price ProductPrice
      ,p.name ProductName
  from `tutorial_demo`.LineItem l
  join `tutorial_demo`.product p
    on l.product_number = p.product_number;

create view `tutorial_demo`.customers_owing as
select name
      ,balance
      ,credit_limit
  from `tutorial_demo`.customer
 where balance > 0;

create view `tutorial_demo`.employee_with_picture
 as
select e.employee_id
      ,e.login
      ,ep.picture
  from `tutorial_demo`.employee e
  left outer join `tutorial_demo`.employee_picture ep
    on e.employee_id = ep.employee_id;

create view `tutorial_demo`.v_LineItem
 as
select l.lineitem_id  LineItemId
      ,l.product_number ProductNumber
      ,l.order_number OrderNumber
      ,l.qty_ordered QuantityOrdered
      ,l.product_price ProductPrice
  from `tutorial_demo`.LineItem l;


DELIMITER $$
CREATE PROCEDURE  `tutorial_demo`.`get_employee` (IN given_employee_id BIGINT
   ,INOUT plus_one BIGINT)
BEGIN
select e.employee_id
       ,plus_one
       ,e.login
       ,ep.icon
       ,ep.picture
       ,ep.voice
   from `tutorial_demo`.employee e
  right outer join `tutorial_demo`.employee_picture ep
     on e.employee_id = ep.employee_id
  where given_employee_id = e.employee_id;
  
  select *
   from `tutorial_demo`.PurchaseOrder
  where given_employee_id = salesrep_id
  order by order_number;
  set plus_one = plus_one + 1;
END$$

DELIMITER ;


DELIMITER $$
CREATE FUNCTION  `tutorial_demo`.`REVERSE` (`@In := Str<">` varchar(4000))
    returns varchar(4000)
    deterministic
    contains sql
  begin
    declare REVSTR varchar(4000) default '';
    declare LEN int;

    if `@In := Str<">` is null then
        return null;
    end if;

    set LEN = length(`@In := Str<">`);
    while LEN > 0 do
      set REVSTR = concat(REVSTR, SUBSTR(`@In := Str<">`, LEN, 1));
      set LEN = LEN - 1;
    end while;

    return REVSTR;
END$$
DELIMITER ;



INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Alpha and Sons', 4484, 9000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Argonauts', 1858, 2000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Baja Software Ltd', 635, 785);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Black Sheep Industries', 76, 10000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Bravo Hardware', 2996, 5000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Charlie''s Construction', 1351, 1500);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Delta Engineering', 2745, 15000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Echo Environmental Services', 2002, 8000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Foxtrot Farm Supply', 2957, 3000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Golf Industries', 3359, 9000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Hotel Services', 4481, 5000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('India Investigators', 5696, 6000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Jack Trading Co.', 46, 3000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Jill Exports Ltd.', 43, 4500);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Juliet Dating Inc.', 1297, 1500);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Kilo Combustibles', 6476, 22000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('La Jolla Ice Cream', 59, 5000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Lima Citrus Supply', 65, 7500);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Mike and Bob''s Construction', 8409, 14000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('November Nuptials Wedding Co', 223, 6800);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Oscar Perterson Music Company', 779, 5000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Papa, Mama and Son Cleaning', 160, 8100);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Quebec Geologic Services', 2979, 13600);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Romeo Restaurant Design', 2024, 6500);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Sam Traders', 0, 3500);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Sierra Backpacking Equipment', 2572, 4900);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Tango Terrestrial Service', 6566, 12300);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Uniform Code Training', 4210, 7800);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Victor Vermin Clearance Co', null, 1900);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Whiskey & Wine Liquor Co', 6238, 6300);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('X-Ray Film Processing', 6331, 7000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Yankee Doodle Bakery', 672, 9000);
INSERT INTO `tutorial_demo`.customer (name, balance, credit_limit) VALUES ('Zulu and Zebras Interiors', 849, 7600);

;INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (1, 'sam', 'Sam Yosemite');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (2, 'mlittlelamb', 'Mary Little-Lamb');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (3, 'sconnor', 'Sarah Connor');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (4, 'jkim', 'John Kim');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (5, 'bmcmanus', 'Becky McManus');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (6, 'ferikson', 'Frank Erikson');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (7, 'pjaveri', 'Peggy Javeri');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (8, 'sfarmer', 'Samantha Farmer');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (9, 'jclark', 'Josh Clark');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (10, 'rgupta', 'Rose Gupta');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (11, 'dcolman', 'Daniel Colman');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (12, 'vjordanoski', 'Vladimir Jordanoski');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (13, 'hchamas', 'Hillary Chamas');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (14, 'ptowers', 'Paul Towers');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (15, 'vglass', 'Val Glass');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (16, 'mvahora', 'Max Vahora');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (17, 'dhansen', 'David Hansen');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (18, 'kbrignoli', 'Katrina Brignoli');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (19, 'honeill', 'Harvey O''Neill');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (20, 'sputin', 'Sasaha Putin');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (21, 'mchang', 'Michael Chang');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (22, 'hsedivy', 'Hima Sedivy');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (23, 'cantonov', 'Christina Antonov');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (24, 'cnoach', 'Carolyn Noach');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (25, 'clee', 'Charlotte Lee');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (26, 'bkersey', 'Bertha Kersey');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (27, 'gryan', 'Greta Ryan');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (28, 'inovotny', 'Isaac Novotny');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (29, 'hcunningham', 'Harold Cunningham');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (30, 'ibobic', 'Irving Bobic');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (37, 'dpugh', 'Doulas Pugh');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (38, 'rtezuysal', 'Robert Tezuysal');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (39, 'hlevis', 'Hank Levis');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (40, 'jsagar', 'Josie Sagar');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (45, 'sarnold', 'Sasank Arnold');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (46, 'scallaghan', 'Saketh Callaghan');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (47, 'dpattishal', 'Dutt Pattishal');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (48, 'sarduini', 'Sathvik Arduini');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (49, 'mguven', 'Morgan Guven');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (50, 'stocker', 'Shriyan Tocker');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (51, 'rpattishal', 'Ryan Pattishal');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (52, 'kgarland', 'Kabila Garland');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (53, 'rseymour', 'Ram Seymour');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (54, 'bbickert', 'Bill Bickert');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (55, 'sbhartia', 'Sushil Bhartia');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (56, 'mtaniguchi', 'Meiyuan Taniguchi');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (57, 'sbouman', 'Shivani Bouman');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (58, 'gbaûnes', 'Gaston Baûnes');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (59, 'srosen', 'Saul Rosen');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (60, 'gbarr', 'Gaurav Barr');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (82, 'gbanda', 'Gopal Banda');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (83, 'bkumar', 'Bhupal Kumar');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (84, 'snidathavolu', 'Supriya Nidathavolu');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (85, 'ssithamraju', 'Sharma Sithamraju');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (86, 'ksaravanan', 'Keerthana Saravanan');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (87, 'vadla', 'Vijayram Adla');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (88, 'savula', 'Sekhar Avula');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (89, 'vvemuri', 'Vidya Vemuri');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (90, 'dbhagat', 'Deepali Bhagat');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (91, 'hyuan', 'Hueyshin Yuan');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (92, 'nlin', 'Niki Lin');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (93, 'schou', 'Shou Chou');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (94, 'adesgrées', 'Alain Desgrées');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (95, 'nkagolanu', 'Nirmal Kagolanu');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (96, 'agonzales', 'Alberto Gonzales');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (97, 'svelpuru', 'Sunita Velpuru');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (98, 'avuyyuru', 'Anita Vuyyuru');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (99, 'kaaviku', 'Kavita Aaviku');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (100, 'lreddi', 'Latha Reddi');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (101, 'pbotcha', 'Prathima Botcha');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (104, 'svasisht', 'Susheera Vasisht');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (105, 'spasumarthy', 'Sajeetha Pasumarthy');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (106, 'szhao', 'Sreshta Zhao');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (107, 'ssheshadri', 'Sushma Sheshadri');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (108, 'bvanukuru', 'Bindu Vanukuru');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (109, 'sdevarajan', 'Shruthi Devarajan');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (110, 'kdev', 'Karthik Dev');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (111, 'adheeraj', 'Amukta Dheeraj');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (112, 'agupta', 'Arpita Gupta');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (113, 'ayalamanchili', 'Aditya Yalamanchili');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (114, 'amcphee', 'Amanda McPhee');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (115, 'rvydehi', 'Rukmini Vydehi');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (116, 'rvenugopal', 'Radhika Venugopal');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (117, 'pkatrapati', 'Prafulla Katrapati');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (118, 'avanflies', 'Arthur van Flies');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (119, 'mshishir', 'Mandakini Shishir');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (120, 'spochiraju', 'Susheela Pochiraju');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (121, 'pdhulipala', 'Pallavi Dhulipala');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (122, 'ctetali', 'Chandana Tetali');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (123, 'nsrinivas', 'Neetu Srinivas');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (124, 'gnagraj', 'Gautami Nagraj');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (125, 'ddhulipala', 'Divya Dhulipala');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (126, 'msharma', 'Mani Sharma');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (127, 'ddeshmukh', 'Deepa Deshmukh');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (128, 'ryu', 'Rohit Yu');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (129, 'kfeng', 'Kavya Feng');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (130, 'vdev', 'Vasu Dev');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (131, 'ddasari', 'Dasu Dasari');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (132, 'bbilahari', 'Babu Bilahari');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (133, 'rnaidu', 'Ramesh Naidu');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (134, 'sfeng', 'Suresh Feng');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (135, 'nkolli', 'Naresh Kolli');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (136, 'kmeduri', 'Kamesh Meduri');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (137, 'schalla', 'Subu Challa');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (138, 'ofeng', 'Oliver Feng');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (139, 'lleoung', 'Lucas Leoung');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (140, 'kwatanabe', 'Kelly Watanabe');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (141, 'spappu', 'Savy Pappu');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (142, 'mmartin', 'Mary Martin');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (143, 'nmukherjee', 'Neil Mukherjee');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (144, 'skleinfeld', 'Sarah Kleinfeld');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (148, 'sparker', 'Sarah Parker');
INSERT INTO `tutorial_demo`.employee (employee_id, login, name) VALUES (149, 'sjones', 'Sam Jones');

;INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (1, 'Hammer', 10);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (2, 'Shovel', 25);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (3, 'Drill', 315);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (4, 'Table saw - 5 hp 38 X 48', 600);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (5, 'Bench grinder', 300);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (6, 'Safety glasses', 13);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (7, 'Framing square w/rafter table', 25);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (8, 'Tape measure 16''', 7);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (9, 'Utility knife', 9);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (10, 'Crosscut saw, 10', 17);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (11, 'Block plane', 24);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (12, 'C clamps/quickie clamps (2)', 15);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (13, 'Wood rasp-comb', 13);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (14, 'Sliding T Bevel', 14);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (15, 'Drill press', 699);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (16, 'Drywall Jab Saw', 12);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (17, 'Vise grip C clamps 2(6"', 5);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (18, 'Rat tail file', 6);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (19, 'Scratch awl', 7);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (20, 'Wrecking bar', 17);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (21, 'Torpedo level', 22);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (22, 'Ripping chisel', 16);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (23, 'Cold chisel', 12);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (24, 'Chalk Box', 6);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (25, 'Hack saw', 19);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (26, 'Surform 4" cutter', 3);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (27, 'Stair gauges', 19);
INSERT INTO `tutorial_demo`.product (product_number, name, price) VALUES (28, 'Nippers (7")', 8);

;INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1, 1079, false, 'This is a small order', 'Alpha and Sons', 2);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (2, 2171, true, '', 'Oscar Perterson Music Company', 8);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (3, 2996, false, 'Please rush this order', 'Bravo Hardware', 15);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (4, 720, false, 'Deliver by overnight with signature required', 'Charlie''s Construction', 2);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (5, 463, false, '', 'Charlie''s Construction', 8);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (6, 108, false, 'Pack with care - fragile merchandise', 'Alpha and Sons', 7);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (7, 1860, false, '', 'Echo Environmental Services', 1);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (8, 171, false, '', 'Kilo Combustibles', 20);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (9, 735, false, 'Deliver to Frank Jones', 'Quebec Geologic Services', 1);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (10, 2024, false, '', 'Romeo Restaurant Design', 1);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (11, 1279, false, '', 'Juliet Dating Inc.', 2);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (12, 4481, false, '', 'Hotel Services', 13);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (13, 1070, false, 'Per Marcy in Acct''g', 'Kilo Combustibles', 20);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (14, 84, false, '', 'Charlie''s Construction', 2);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (15, 142, false, '', 'Echo Environmental Services', 11);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (16, 2745, false, 'For Krask project', 'Delta Engineering', 9);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (17, 2898, false, '', 'Tango Terrestrial Service', 12);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (18, 5269, false, 'Rush need tomorrow', 'X-Ray Film Processing', 10);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (19, 2002, false, '', 'Quebec Geologic Services', 6);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (20, 1848, false, '', 'Argonauts', 5);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (21, 712, false, '', 'Zulu and Zebras Interiors', 15);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (22, 617, false, 'Attention Cary Burch', 'Yankee Doodle Bakery', 17);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (23, 52, false, '', 'India Investigators', 11);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (24, 242, false, '', 'Quebec Geologic Services', 18);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (25, 65, false, '', 'Lima Citrus Supply', 1);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (26, 110, false, '', 'Foxtrot Farm Supply', 6);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (27, 360, false, 'deliver to plant floor', 'Golf Industries', 17);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (28, 160, false, '', 'Papa, Mama and Son Cleaning', 9);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (29, 223, false, '', 'November Nuptials Wedding Co', 3);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (31, 80, false, '', 'Zulu and Zebras Interiors', 7);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (32, 2245, false, '', 'Golf Industries', 4);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (33, 2465, false, '', 'Sierra Backpacking Equipment', 19);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (34, 147, false, '', 'Mike and Bob''s Construction', 17);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (35, 1001, true, '', 'Juliet Dating Inc.', 17);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (37, 3668, false, '', 'Tango Terrestrial Service', 18);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (38, 55, false, '', 'Yankee Doodle Bakery', 13);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (39, 107, false, '', 'Sierra Backpacking Equipment', 5);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (43, 754, false, '', 'Golf Industries', 11);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (45, 779, false, '', 'Oscar Perterson Music Company', 18);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (46, 2847, false, '', 'Foxtrot Farm Supply', 11);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (47, 202, false, '', 'Mike and Bob''s Construction', 7);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (48, 18, false, '', 'Juliet Dating Inc.', 16);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (49, 57, false, '', 'Zulu and Zebras Interiors', 10);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (51, 2726, false, '', 'Whiskey & Wine Liquor Co', 17);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (52, 1062, false, '', 'X-Ray Film Processing', 7);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (53, 5235, false, '', 'Kilo Combustibles', 7);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (54, 8060, false, '', 'Mike and Bob''s Construction', 3);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (55, 28, false, '', 'Whiskey & Wine Liquor Co', 8);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (56, 1447, false, '', 'India Investigators', 19);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1000, 4197, false, '', 'India Investigators', 16);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1001, 3484, false, '', 'Whiskey & Wine Liquor Co', 3);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1002, 4210, false, '', 'Uniform Code Training', 4);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1003, 82, false, '', 'Alpha and Sons', 3);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1007, 943, false, '', 'Alpha and Sons', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1010, 100000, false, '', 'Argonauts', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1021, 2272, false, '', 'Alpha and Sons', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1038, 635, false, '', 'Baja Software Ltd', 1);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1043, 41, false, '', 'Black Sheep Industries', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1044, 46, false, '', 'Jack Trading Co.', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1045, 43, false, '', 'Jill Exports Ltd.', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1046, 59, false, '', 'La Jolla Ice Cream', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1050, 35, false, '', 'Black Sheep Industries', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1051, 0, false, '', 'Alpha and Sons', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1052, 0, false, '', 'Alpha and Sons', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1053, 0, false, '', 'Argonauts', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1054, 0, false, '', 'Baja Software Ltd', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1055, 0, false, '', 'Bravo Hardware', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1056, 0, false, '', 'Alpha and Sons', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1057, 0, false, '', 'Alpha and Sons', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1061, 0, false, '', 'Sierra Backpacking Equipment', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1064, 0, false, '', 'Zulu and Zebras Interiors', null);
INSERT INTO `tutorial_demo`.PurchaseOrder (order_number, amount_total, paid, notes, customer_name, salesrep_id) VALUES (1065, 0, false, '', 'Victor Vermin Clearance Co', null);

;INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1, 4, 1, 1, 600, 600);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (2, 1, 2, 2, 10, 20);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (3, 2, 2, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (4, 3, 2, 2, 315, 630);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (5, 1, 3, 1, 10, 10);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (6, 2, 3, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (7, 1, 4, 1, 10, 10);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (8, 2, 4, 3, 25, 75);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (9, 1, 5, 1, 10, 10);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (10, 2, 5, 5, 25, 125);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (11, 2, 6, 2, 25, 50);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (12, 2, 1, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1000, 1, 9, 1, 10, 10);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1001, 2, 9, 2, 25, 50);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1002, 3, 9, 2, 315, 630);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1003, 1, 9, 2, 10, 20);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1004, 2, 9, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1005, 1, 7, 1, 10, 10);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1006, 2, 7, 2, 25, 50);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1007, 4, 7, 2, 600, 1200);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1008, 5, 7, 2, 300, 600);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1009, 6, 8, 1, 13, 13);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1010, 7, 8, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1011, 8, 8, 2, 7, 14);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1012, 9, 8, 2, 9, 18);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1013, 10, 8, 3, 17, 51);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1015, 7, 8, 2, 25, 50);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1016, 14, 20, 0, 14, 0);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1017, 15, 21, 1, 699, 699);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1018, 13, 21, 1, 13, 13);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1019, 14, 10, 5, 14, 70);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1020, 10, 10, 2, 17, 34);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1021, 4, 12, 3, 600, 1800);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1022, 15, 12, 2, 699, 1398);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1023, 8, 12, 3, 7, 21);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1024, 28, 11, 1, 8, 8);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1025, 19, 11, 2, 7, 14);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1026, 27, 11, 3, 19, 57);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1027, 13, 13, 3, 13, 39);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1028, 14, 13, 4, 14, 56);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1029, 18, 14, 5, 6, 30);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1030, 20, 14, 1, 17, 17);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1031, 19, 14, 5, 7, 35);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1032, 12, 15, 5, 15, 75);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1033, 2, 16, 5, 25, 125);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1034, 15, 18, 3, 699, 2097);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1035, 12, 18, 5, 15, 75);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1036, 5, 18, 4, 300, 1200);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1037, 19, 17, 5, 7, 35);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1038, 10, 17, 1, 17, 17);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1039, 7, 17, 2, 25, 50);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1040, 24, 19, 2, 6, 12);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1041, 11, 16, 5, 24, 120);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1042, 25, 19, 5, 19, 95);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1043, 23, 19, 2, 12, 24);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1044, 26, 18, 5, 3, 15);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1045, 18, 24, 4, 6, 24);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1046, 2, 29, 5, 25, 125);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1047, 28, 29, 4, 8, 32);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1048, 24, 28, 5, 6, 30);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1049, 8, 28, 4, 7, 28);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1050, 10, 28, 6, 17, 102);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1051, 17, 26, 3, 5, 15);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1052, 25, 26, 5, 19, 95);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1053, 6, 25, 5, 13, 65);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1054, 19, 24, 4, 7, 28);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1055, 21, 24, 5, 22, 110);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1056, 22, 24, 5, 16, 80);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1057, 13, 23, 4, 13, 52);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1058, 4, 22, 1, 600, 600);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1059, 20, 22, 1, 17, 17);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1060, 16, 29, 5, 12, 60);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1061, 26, 29, 2, 3, 6);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1062, 7, 34, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1063, 13, 34, 4, 13, 52);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1064, 14, 34, 5, 14, 70);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1065, 6, 47, 5, 13, 65);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1066, 25, 47, 3, 19, 57);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1067, 25, 47, 2, 19, 38);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1068, 14, 47, 3, 14, 42);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1069, 9, 3, 2, 9, 18);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1070, 5, 45, 2, 300, 600);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1071, 10, 45, 4, 17, 68);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1072, 11, 45, 3, 24, 72);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1073, 13, 45, 3, 13, 39);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1074, 17, 27, 3, 5, 15);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1075, 8, 27, 4, 7, 28);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1076, 10, 27, 1, 17, 17);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1077, 5, 27, 1, 300, 300);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1078, 19, 32, 1, 7, 7);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1079, 15, 32, 3, 699, 2097);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1080, 10, 32, 5, 17, 85);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1081, 18, 32, 5, 6, 30);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1082, 13, 32, 2, 13, 26);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1083, 15, 43, 1, 699, 699);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1084, 25, 43, 2, 19, 38);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1085, 20, 43, 1, 17, 17);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1086, 6, 33, 3, 13, 39);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1087, 13, 33, 2, 13, 26);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1088, 4, 33, 4, 600, 2400);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1089, 25, 39, 1, 19, 19);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1090, 24, 39, 1, 6, 6);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1091, 18, 39, 2, 6, 12);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1092, 23, 39, 4, 12, 48);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1093, 21, 39, 1, 22, 22);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1096, 3, 1, 1, 315, 315);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1097, 2, 1, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1098, 8, 1, 2, 7, 14);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1099, 7, 1, 2, 25, 50);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1100, 11, 1, 1, 24, 24);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1101, 10, 1, 1, 17, 17);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1102, 9, 1, 1, 9, 9);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1103, 8, 2, 2, 7, 14);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1104, 6, 2, 2, 13, 26);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1105, 10, 2, 2, 17, 34);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1106, 15, 2, 2, 699, 1398);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1107, 16, 2, 2, 12, 24);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1108, 2, 3, 3, 25, 75);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1109, 3, 3, 3, 315, 945);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1110, 4, 3, 3, 600, 1800);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1111, 7, 3, 3, 25, 75);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1112, 8, 3, 3, 7, 21);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1113, 9, 3, 3, 9, 27);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1114, 4, 10, 3, 600, 1800);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1115, 6, 10, 3, 13, 39);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1116, 9, 10, 2, 9, 18);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1117, 11, 10, 2, 24, 48);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1118, 12, 10, 1, 15, 15);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1119, 7, 1003, 2, 25, 50);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1120, 8, 1003, 1, 7, 7);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1121, 2, 1003, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1122, 4, 11, 2, 600, 1200);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1124, 5, 12, 3, 300, 900);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1125, 7, 12, 2, 25, 50);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1126, 8, 12, 2, 7, 14);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1127, 6, 12, 2, 13, 26);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1128, 7, 12, 3, 25, 75);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1129, 8, 12, 2, 7, 14);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1130, 9, 12, 3, 9, 27);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1131, 11, 12, 4, 24, 96);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1132, 12, 12, 4, 15, 60);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1139, 2, 13, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1140, 1, 13, 1, 10, 10);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1141, 3, 13, 1, 315, 315);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1142, 4, 13, 1, 600, 600);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1143, 7, 13, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1144, 6, 14, 1, 13, 13);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1145, 7, 14, 2, 25, 50);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1147, 8, 14, 2, 7, 14);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1148, 9, 14, 1, 9, 9);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1164, 1, 16, 2, 10, 20);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1165, 2, 16, 2, 25, 50);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1166, 3, 16, 2, 315, 630);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1167, 4, 16, 2, 600, 1200);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1168, 5, 16, 2, 300, 600);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1169, 5, 17, 3, 300, 900);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1170, 4, 17, 3, 600, 1800);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1171, 7, 17, 3, 25, 75);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1172, 8, 17, 3, 7, 21);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1173, 2, 18, 2, 25, 50);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1174, 4, 18, 2, 600, 1200);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1175, 5, 18, 2, 300, 600);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1176, 8, 18, 2, 7, 14);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1177, 9, 18, 2, 9, 18);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1178, 2, 19, 2, 25, 50);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1180, 4, 19, 3, 600, 1800);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1181, 8, 19, 3, 7, 21);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1199, 11, 52, 2, 24, 48);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1200, 5, 52, 1, 300, 300);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1201, 15, 52, 1, 699, 699);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1202, 12, 52, 1, 15, 15);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1203, 6, 38, 1, 13, 13);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1204, 9, 38, 1, 9, 9);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1205, 13, 38, 2, 13, 26);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1206, 19, 38, 1, 7, 7);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1212, 4, 46, 4, 600, 2400);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1213, 7, 46, 4, 25, 100);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1214, 8, 46, 5, 7, 35);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1215, 18, 46, 2, 6, 12);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1216, 5, 46, 1, 300, 300);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1217, 4, 1002, 2, 600, 1200);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1218, 5, 1002, 3, 300, 900);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1219, 15, 1002, 3, 699, 2097);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1220, 6, 1002, 1, 13, 13);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1221, 4, 1001, 1, 600, 600);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1222, 6, 1001, 1, 13, 13);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1223, 16, 1001, 3, 12, 36);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1224, 13, 1001, 3, 13, 39);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1225, 15, 1001, 4, 699, 2796);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1226, 4, 1000, 2, 600, 1200);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1227, 5, 1000, 3, 300, 900);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1228, 15, 1000, 3, 699, 2097);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1232, 5, 51, 3, 300, 900);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1233, 4, 51, 3, 600, 1800);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1234, 6, 51, 2, 13, 26);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1235, 4, 53, 3, 600, 1800);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1236, 15, 53, 4, 699, 2796);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1237, 5, 53, 2, 300, 600);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1238, 6, 53, 3, 13, 39);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1313, 12, 55, 1, 15, 15);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1314, 6, 55, 1, 13, 13);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1315, 4, 54, 5, 600, 3000);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1316, 5, 54, 5, 300, 1500);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1317, 15, 54, 5, 699, 3495);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1318, 6, 54, 5, 13, 65);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1319, 9, 48, 2, 9, 18);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1323, 14, 56, 1, 14, 14);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1324, 15, 56, 2, 699, 1398);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1325, 8, 56, 5, 7, 35);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1326, 9, 31, 4, 9, 36);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1327, 18, 31, 4, 6, 24);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1328, 17, 31, 4, 5, 20);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1329, 21, 37, 3, 22, 66);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1330, 26, 37, 4, 3, 12);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1331, 27, 37, 5, 19, 95);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1332, 15, 37, 5, 699, 3495);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1333, 12, 49, 3, 15, 45);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1334, 23, 49, 1, 12, 12);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1335, 4, 1038, 1, 600, 600);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1336, 2, 1038, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1337, 1, 1038, 1, 10, 10);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1338, 9, 1043, 1, 9, 9);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1339, 7, 1043, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1340, 8, 1043, 1, 7, 7);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1341, 6, 1044, 1, 13, 13);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1342, 9, 1044, 1, 9, 9);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1343, 11, 1044, 1, 24, 24);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1344, 9, 1045, 1, 9, 9);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1345, 1, 1045, 1, 10, 10);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1346, 11, 1045, 1, 24, 24);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1347, 8, 1046, 1, 7, 7);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1348, 11, 1046, 1, 24, 24);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1349, 12, 1046, 1, 15, 15);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1350, 13, 1046, 1, 13, 13);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1360, 1, 4, 1, 10, 10);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1361, 2, 4, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1362, 4, 4, 1, 600, 600);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1367, 5, 1050, 0, 300, 0);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1368, 4, 1050, 0, 600, 0);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1369, 2, 1050, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1370, 1, 1050, 1, 10, 10);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1371, 3, 5, 1, 315, 315);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1372, 6, 5, 1, 13, 13);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1373, 10, 6, 1, 17, 17);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1374, 9, 6, 1, 9, 9);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1375, 7, 6, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1376, 8, 6, 1, 7, 7);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1377, 8, 15, 1, 7, 7);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1378, 7, 15, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1379, 2, 15, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1380, 1, 15, 1, 10, 10);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1381, 1, 20, 1, 10, 10);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1382, 2, 20, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1383, 4, 20, 1, 600, 600);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1384, 4, 20, 2, 600, 1200);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1385, 6, 20, 1, 13, 13);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1386, 7, 35, 2, 25, 50);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1387, 14, 35, 3, 14, 42);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1388, 28, 35, 4, 8, 32);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1389, 26, 35, 2, 3, 6);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1390, 25, 35, 3, 19, 57);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1391, 23, 35, 2, 12, 24);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1392, 27, 35, 3, 19, 57);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1393, 10, 35, 2, 17, 34);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1394, 15, 35, 1, 699, 699);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1407, 16, 1007, 2, 12, 24);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1408, 9, 1007, 1, 9, 9);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1409, 5, 1007, 1, 300, 300);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1410, 4, 1007, 1, 600, 600);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1411, 1, 1007, 1, 10, 10);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1412, 1, 1021, 1, 10, 10);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1413, 2, 1021, 1, 25, 25);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1414, 3, 1021, 1, 315, 315);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1415, 4, 1021, 2, 600, 1200);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1416, 5, 1021, 2, 300, 600);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1417, 6, 1021, 2, 13, 26);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1418, 7, 1021, 3, 25, 75);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1419, 8, 1021, 3, 7, 21);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1423, 1, 1010, 1, 10, 10);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1424, 4, 1010, 0, 600, 0);
INSERT INTO `tutorial_demo`.LineItem (lineitem_id, product_number, order_number, qty_ordered, product_price, amount) VALUES (1425, 10, 1010, 0, 17, 0);

;INSERT INTO `tutorial_demo`.employee_picture (employee_id, icon, picture, voice, resume) values (1, null, null, null, null);



alter table `tutorial_demo`.LineItem
  add constraint product
  foreign key(product_number)
  references `tutorial_demo`.product (product_number)
  on update cascade;

alter table`tutorial_demo`.LineItem
  add constraint lineitem_purchaseorder
  foreign key(order_number)
  references `tutorial_demo`.PurchaseOrder (order_number)
  on delete cascade on update cascade;

alter table `tutorial_demo`.PurchaseOrder
  add constraint customer
  foreign key(customer_name)
  references `tutorial_demo`.customer (name)
  on delete cascade on update cascade;

alter table `tutorial_demo`.PurchaseOrder
  add constraint salesrep
  foreign key(salesrep_id)
  references `tutorial_demo`.employee (employee_id)
  on delete cascade on update cascade;

alter table `tutorial_demo`.employee_picture
  add constraint employee_picture
  foreign key(employee_id)
  references `tutorial_demo`.employee (employee_id)
  on delete cascade on update cascade;

alter table `tutorial_demo`.purchaseorder_audit
  add constraint purchaseorder_audit
  foreign key(order_number)
  references `tutorial_demo`.PurchaseOrder (order_number)
  on delete cascade on update cascade;

COMMIT;

GRANT EXECUTE ON PROCEDURE `tutorial_demo`.get_employee TO 'tutorial_demo'@'%';

GRANT EXECUTE ON PROCEDURE `tutorial_demo`.get_employee TO 'tutorial_demo'@'localhost';

FLUSH PRIVILEGES;