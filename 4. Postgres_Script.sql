-- ------------ Write CREATE-DATABASE-stage scripts -----------

CREATE SCHEMA IF NOT EXISTS sourcefuse_db_dbo;

-- ------------ Write CREATE-TABLE-stage scripts -----------

CREATE TABLE sourcefuse_db_dbo."Order Details"(
    orderid INTEGER NOT NULL,
    productid INTEGER NOT NULL,
    unitprice NUMERIC(19,4) NOT NULL DEFAULT (0),
    quantity SMALLINT NOT NULL DEFAULT (1),
    discount DOUBLE PRECISION NOT NULL DEFAULT (0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sourcefuse_db_dbo.categories(
    categoryid INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY,
    categoryname VARCHAR(15) NOT NULL,
    description TEXT,
    picture BYTEA
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sourcefuse_db_dbo.customercustomerdemo(
    customerid CHAR(5) NOT NULL,
    customertypeid CHAR(10) NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sourcefuse_db_dbo.customerdemographics(
    customertypeid CHAR(10) NOT NULL,
    customerdesc TEXT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sourcefuse_db_dbo.customers(
    customerid CHAR(5) NOT NULL,
    companyname VARCHAR(40) NOT NULL,
    contactname VARCHAR(30),
    contacttitle VARCHAR(30),
    address VARCHAR(60),
    city VARCHAR(15),
    region VARCHAR(15),
    postalcode VARCHAR(10),
    country VARCHAR(15),
    phone VARCHAR(24),
    fax VARCHAR(24)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sourcefuse_db_dbo.employees(
    employeeid INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY,
    lastname VARCHAR(20) NOT NULL,
    firstname VARCHAR(10) NOT NULL,
    title VARCHAR(30),
    titleofcourtesy VARCHAR(25),
    birthdate TIMESTAMP WITHOUT TIME ZONE,
    hiredate TIMESTAMP WITHOUT TIME ZONE,
    address VARCHAR(60),
    city VARCHAR(15),
    region VARCHAR(15),
    postalcode VARCHAR(10),
    country VARCHAR(15),
    homephone VARCHAR(24),
    extension VARCHAR(4),
    photo BYTEA,
    notes TEXT,
    reportsto INTEGER,
    photopath VARCHAR(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sourcefuse_db_dbo.employeeterritories(
    employeeid INTEGER NOT NULL,
    territoryid VARCHAR(20) NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sourcefuse_db_dbo.orders(
    orderid INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY,
    customerid CHAR(5),
    employeeid INTEGER,
    orderdate TIMESTAMP WITHOUT TIME ZONE,
    requireddate TIMESTAMP WITHOUT TIME ZONE,
    shippeddate TIMESTAMP WITHOUT TIME ZONE,
    shipvia INTEGER,
    freight NUMERIC(19,4) DEFAULT (0),
    shipname VARCHAR(40),
    shipaddress VARCHAR(60),
    shipcity VARCHAR(15),
    shipregion VARCHAR(15),
    shippostalcode VARCHAR(10),
    shipcountry VARCHAR(15)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sourcefuse_db_dbo.products(
    productid INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY,
    productname VARCHAR(40) NOT NULL,
    supplierid INTEGER,
    categoryid INTEGER,
    quantityperunit VARCHAR(20),
    unitprice NUMERIC(19,4) DEFAULT (0),
    unitsinstock SMALLINT DEFAULT (0),
    unitsonorder SMALLINT DEFAULT (0),
    reorderlevel SMALLINT DEFAULT (0),
    discontinued NUMERIC(1,0) NOT NULL DEFAULT (0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sourcefuse_db_dbo.region(
    regionid INTEGER NOT NULL,
    regiondescription CHAR(50) NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sourcefuse_db_dbo.shippers(
    shipperid INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY,
    companyname VARCHAR(40) NOT NULL,
    phone VARCHAR(24)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sourcefuse_db_dbo.suppliers(
    supplierid INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY,
    companyname VARCHAR(40) NOT NULL,
    contactname VARCHAR(30),
    contacttitle VARCHAR(30),
    address VARCHAR(60),
    city VARCHAR(15),
    region VARCHAR(15),
    postalcode VARCHAR(10),
    country VARCHAR(15),
    phone VARCHAR(24),
    fax VARCHAR(24),
    homepage TEXT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sourcefuse_db_dbo.territories(
    territoryid VARCHAR(20) NOT NULL,
    territorydescription CHAR(50) NOT NULL,
    regionid INTEGER NOT NULL
)
        WITH (
        OIDS=FALSE
        );

-- ------------ Write CREATE-VIEW-stage scripts -----------

CREATE OR REPLACE  VIEW sourcefuse_db_dbo."Alphabetical list of products" (productid, productname, supplierid, categoryid, quantityperunit, unitprice, unitsinstock, unitsonorder, reorderlevel, discontinued, categoryname) AS
SELECT
    sourcefuse_db_dbo.products.*, categories.categoryname
    FROM sourcefuse_db_dbo.categories
    INNER JOIN sourcefuse_db_dbo.products
        ON categories.categoryid = products.ix_products_categoryid
    WHERE (((products.discontinued) = 0));

CREATE OR REPLACE  VIEW sourcefuse_db_dbo."Category Sales for 1997" (categoryname, categorysales) AS
SELECT
    "Product Sales for 1997".categoryname, SUM("Product Sales for 1997".productsales) AS categorysales
    FROM sourcefuse_db_dbo."Product Sales for 1997"
    GROUP BY "Product Sales for 1997".categoryname;

CREATE OR REPLACE  VIEW sourcefuse_db_dbo."Current Product List" (productid, productname) AS
SELECT
    product_list.productid, product_list.productname
    FROM sourcefuse_db_dbo.products AS product_list
    WHERE (((product_list.discontinued) = 0));
/* ORDER BY Product_List.ProductName */;

CREATE OR REPLACE  VIEW sourcefuse_db_dbo."Customer and Suppliers by City" (city, companyname, contactname, relationship) AS
SELECT
    city, companyname, contactname, 'Customers'::TEXT AS relationship
    FROM sourcefuse_db_dbo.customers
UNION
SELECT
    city, companyname, contactname, 'Suppliers'::TEXT
    FROM sourcefuse_db_dbo.suppliers;
/* ORDER BY City, CompanyName */;

CREATE OR REPLACE  VIEW sourcefuse_db_dbo."Order Details Extended" (orderid, productid, productname, unitprice, quantity, discount, extendedprice) AS
SELECT
    "Order Details".orderid, "Order Details".productid, products.productname, "Order Details".unitprice, "Order Details".quantity, "Order Details".discount, (CAST (("Order Details".unitprice * quantity * (1 - discount) / 100) AS NUMERIC(19, 4)) * 100) AS extendedprice
    FROM sourcefuse_db_dbo.products
    INNER JOIN sourcefuse_db_dbo."Order Details"
        ON products.productid = "Order Details"."IX_Order Details_ProductID";
/* ORDER BY "Order Details".OrderID */;

CREATE OR REPLACE  VIEW sourcefuse_db_dbo."Order Subtotals" (orderid, subtotal) AS
SELECT
    "Order Details".orderid, SUM(CAST (("Order Details".unitprice * quantity * (1 - discount) / 100) AS NUMERIC(19, 4)) * 100) AS subtotal
    FROM sourcefuse_db_dbo."Order Details"
    GROUP BY "Order Details"."IX_Order Details_OrderID";

CREATE OR REPLACE  VIEW sourcefuse_db_dbo."Orders Qry" (orderid, customerid, employeeid, orderdate, requireddate, shippeddate, shipvia, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry, companyname, address, city, region, postalcode, country) AS
SELECT
    orders.orderid, orders.customerid, orders.employeeid, orders.orderdate, orders.requireddate, orders.shippeddate, orders.shipvia, orders.freight, orders.shipname, orders.shipaddress, orders.shipcity, orders.shipregion, orders.shippostalcode, orders.shipcountry, customers.companyname, customers.address, customers.city, customers.region, customers.postalcode, customers.country
    FROM sourcefuse_db_dbo.customers
    INNER JOIN sourcefuse_db_dbo.orders
        ON LOWER(customers.customerid) = LOWER(orders.ix_orders_customerid);

CREATE OR REPLACE  VIEW sourcefuse_db_dbo."Product Sales for 1997" (categoryname, productname, productsales) AS
SELECT
    categories.categoryname, products.productname, SUM(CAST (("Order Details".unitprice * quantity * (1 - discount) / 100) AS NUMERIC(19, 4)) * 100) AS productsales
    FROM (sourcefuse_db_dbo.categories
    INNER JOIN sourcefuse_db_dbo.products
        ON categories.categoryid = products.ix_products_categoryid)
    INNER JOIN (sourcefuse_db_dbo.orders
    INNER JOIN sourcefuse_db_dbo."Order Details"
        ON orders.orderid = "Order Details"."IX_Order Details_OrderID")
        ON products.productid = "Order Details"."IX_Order Details_ProductID"
    WHERE (((orders.ix_orders_shippeddate) BETWEEN '19970101' AND '19971231'))
    GROUP BY categories.ix_categories_categoryname, products.ix_products_productname;

CREATE OR REPLACE  VIEW sourcefuse_db_dbo."Products Above Average Price" (productname, unitprice) AS
SELECT
    products.productname, products.unitprice
    FROM sourcefuse_db_dbo.products
    WHERE products.unitprice > (SELECT
        AVG(unitprice)
        FROM sourcefuse_db_dbo.products);
/* ORDER BY Products.UnitPrice DESC */;

CREATE OR REPLACE  VIEW sourcefuse_db_dbo."Products by Category" (categoryname, productname, quantityperunit, unitsinstock, discontinued) AS
SELECT
    categories.categoryname, products.productname, products.quantityperunit, products.unitsinstock, products.discontinued
    FROM sourcefuse_db_dbo.categories
    INNER JOIN sourcefuse_db_dbo.products
        ON categories.categoryid = products.ix_products_categoryid
    WHERE products.discontinued <> 1;
/* ORDER BY Categories.CategoryName, Products.ProductName */;

CREATE OR REPLACE  VIEW sourcefuse_db_dbo."Quarterly Orders" (customerid, companyname, city, country) AS
SELECT DISTINCT
    customers.customerid, customers.companyname, customers.city, customers.country
    FROM sourcefuse_db_dbo.customers
    RIGHT OUTER JOIN sourcefuse_db_dbo.orders
        ON LOWER(customers.customerid) = LOWER(orders.ix_orders_customerid)
    WHERE orders.ix_orders_orderdate BETWEEN '19970101' AND '19971231';

CREATE OR REPLACE  VIEW sourcefuse_db_dbo."Sales Totals by Amount" (saleamount, orderid, companyname, shippeddate) AS
SELECT
    "Order Subtotals".subtotal AS saleamount, orders.orderid, customers.companyname, orders.shippeddate
    FROM sourcefuse_db_dbo.customers
    INNER JOIN (sourcefuse_db_dbo.orders
    INNER JOIN sourcefuse_db_dbo."Order Subtotals"
        ON orders.orderid = "Order Subtotals".orderid)
        ON LOWER(customers.customerid) = LOWER(orders.ix_orders_customerid)
    WHERE ("Order Subtotals".subtotal > 2500) AND (orders.ix_orders_shippeddate BETWEEN '19970101' AND '19971231');

CREATE OR REPLACE  VIEW sourcefuse_db_dbo."Sales by Category" (categoryid, categoryname, productname, productsales) AS
SELECT
    categories.categoryid, categories.categoryname, products.productname, SUM("Order Details Extended".extendedprice) AS productsales
    FROM sourcefuse_db_dbo.categories
    INNER JOIN (sourcefuse_db_dbo.products
    INNER JOIN (sourcefuse_db_dbo.orders
    INNER JOIN sourcefuse_db_dbo."Order Details Extended"
        ON orders.orderid = "Order Details Extended".orderid)
        ON products.productid = "Order Details Extended".productid)
        ON categories.categoryid = products.ix_products_categoryid
    WHERE orders.ix_orders_orderdate BETWEEN '19970101' AND '19971231'
    GROUP BY categories.categoryid, categories.ix_categories_categoryname, products.ix_products_productname;
/* ORDER BY Products.ProductName */;

CREATE OR REPLACE  VIEW sourcefuse_db_dbo."Summary of Sales by Quarter" (shippeddate, orderid, subtotal) AS
SELECT
    orders.shippeddate, orders.orderid, "Order Subtotals".subtotal
    FROM sourcefuse_db_dbo.orders
    INNER JOIN sourcefuse_db_dbo."Order Subtotals"
        ON orders.orderid = "Order Subtotals".orderid
    WHERE orders.ix_orders_shippeddate IS NOT NULL;
/* ORDER BY Orders.ShippedDate */;

CREATE OR REPLACE  VIEW sourcefuse_db_dbo."Summary of Sales by Year" (shippeddate, orderid, subtotal) AS
SELECT
    orders.shippeddate, orders.orderid, "Order Subtotals".subtotal
    FROM sourcefuse_db_dbo.orders
    INNER JOIN sourcefuse_db_dbo."Order Subtotals"
        ON orders.orderid = "Order Subtotals".orderid
    WHERE orders.ix_orders_shippeddate IS NOT NULL;
/* ORDER BY Orders.ShippedDate */;

CREATE OR REPLACE  VIEW sourcefuse_db_dbo.invoices (shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry, customerid, customername, address, city, region, postalcode, country, salesperson, orderid, orderdate, requireddate, shippeddate, shippername, productid, productname, unitprice, quantity, discount, extendedprice, freight) AS
SELECT
    orders.shipname, orders.shipaddress, orders.shipcity, orders.shipregion, orders.shippostalcode, orders.shipcountry, orders.customerid, customers.companyname AS customername, customers.address, customers.city, customers.region, customers.postalcode, customers.country, (firstname || ' ' || lastname) AS salesperson, orders.orderid, orders.orderdate, orders.requireddate, orders.shippeddate, shippers.companyname AS shippername, "Order Details".productid, products.productname, "Order Details".unitprice, "Order Details".quantity, "Order Details".discount, (CAST (("Order Details".unitprice * quantity * (1 - discount) / 100) AS NUMERIC(19, 4)) * 100) AS extendedprice, orders.freight
    FROM sourcefuse_db_dbo.shippers
    INNER JOIN (sourcefuse_db_dbo.products
    INNER JOIN ((sourcefuse_db_dbo.employees
    INNER JOIN (sourcefuse_db_dbo.customers
    INNER JOIN sourcefuse_db_dbo.orders
        ON LOWER(customers.customerid) = LOWER(orders.ix_orders_customerid))
        ON employees.employeeid = orders.ix_orders_employeeid)
    INNER JOIN sourcefuse_db_dbo."Order Details"
        ON orders.orderid = "Order Details"."IX_Order Details_OrderID")
        ON products.productid = "Order Details"."IX_Order Details_ProductID")
        ON shippers.shipperid = orders.shipvia;

-- ------------ Write CREATE-INDEX-stage scripts -----------

CREATE INDEX "IX_Order Details_OrderID"
ON sourcefuse_db_dbo."Order Details"
USING BTREE (orderid ASC);

CREATE INDEX "IX_Order Details_OrdersOrder_Details"
ON sourcefuse_db_dbo."Order Details"
USING BTREE (orderid ASC);

CREATE INDEX "IX_Order Details_ProductID"
ON sourcefuse_db_dbo."Order Details"
USING BTREE (productid ASC);

CREATE INDEX "IX_Order Details_ProductsOrder_Details"
ON sourcefuse_db_dbo."Order Details"
USING BTREE (productid ASC);

CREATE INDEX ix_categories_categoryname
ON sourcefuse_db_dbo.categories
USING BTREE (categoryname ASC);

CREATE INDEX ix_customers_city
ON sourcefuse_db_dbo.customers
USING BTREE (city ASC);

CREATE INDEX ix_customers_companyname
ON sourcefuse_db_dbo.customers
USING BTREE (companyname ASC);

CREATE INDEX ix_customers_postalcode
ON sourcefuse_db_dbo.customers
USING BTREE (postalcode ASC);

CREATE INDEX ix_customers_region
ON sourcefuse_db_dbo.customers
USING BTREE (region ASC);

CREATE INDEX ix_employees_lastname
ON sourcefuse_db_dbo.employees
USING BTREE (lastname ASC);

CREATE INDEX ix_employees_postalcode
ON sourcefuse_db_dbo.employees
USING BTREE (postalcode ASC);

CREATE INDEX ix_orders_customerid
ON sourcefuse_db_dbo.orders
USING BTREE (customerid ASC);

CREATE INDEX ix_orders_customersorders
ON sourcefuse_db_dbo.orders
USING BTREE (customerid ASC);

CREATE INDEX ix_orders_employeeid
ON sourcefuse_db_dbo.orders
USING BTREE (employeeid ASC);

CREATE INDEX ix_orders_employeesorders
ON sourcefuse_db_dbo.orders
USING BTREE (employeeid ASC);

CREATE INDEX ix_orders_orderdate
ON sourcefuse_db_dbo.orders
USING BTREE (orderdate ASC);

CREATE INDEX ix_orders_shippeddate
ON sourcefuse_db_dbo.orders
USING BTREE (shippeddate ASC);

CREATE INDEX ix_orders_shippersorders
ON sourcefuse_db_dbo.orders
USING BTREE (shipvia ASC);

CREATE INDEX ix_orders_shippostalcode
ON sourcefuse_db_dbo.orders
USING BTREE (shippostalcode ASC);

CREATE INDEX ix_products_categoriesproducts
ON sourcefuse_db_dbo.products
USING BTREE (categoryid ASC);

CREATE INDEX ix_products_categoryid
ON sourcefuse_db_dbo.products
USING BTREE (categoryid ASC);

CREATE INDEX ix_products_productname
ON sourcefuse_db_dbo.products
USING BTREE (productname ASC);

CREATE INDEX ix_products_supplierid
ON sourcefuse_db_dbo.products
USING BTREE (supplierid ASC);

CREATE INDEX ix_products_suppliersproducts
ON sourcefuse_db_dbo.products
USING BTREE (supplierid ASC);

CREATE INDEX ix_suppliers_companyname
ON sourcefuse_db_dbo.suppliers
USING BTREE (companyname ASC);

CREATE INDEX ix_suppliers_postalcode
ON sourcefuse_db_dbo.suppliers
USING BTREE (postalcode ASC);

-- ------------ Write CREATE-CONSTRAINT-stage scripts -----------

ALTER TABLE sourcefuse_db_dbo."Order Details"
ADD CONSTRAINT ck_discount_853578079 CHECK (
(discount >= (0) AND discount <= (1)));

ALTER TABLE sourcefuse_db_dbo."Order Details"
ADD CONSTRAINT ck_quantity_869578136 CHECK (
(quantity > (0)));

ALTER TABLE sourcefuse_db_dbo."Order Details"
ADD CONSTRAINT ck_unitprice_885578193 CHECK (
(unitprice >= (0)));

ALTER TABLE sourcefuse_db_dbo."Order Details"
ADD CONSTRAINT pk_order_details_757577737 PRIMARY KEY (orderid, productid);

ALTER TABLE sourcefuse_db_dbo.categories
ADD CONSTRAINT pk_categories_325576198 PRIMARY KEY (categoryid);

ALTER TABLE sourcefuse_db_dbo.customercustomerdemo
ADD CONSTRAINT pk_customercustomerdemo_1349579846 PRIMARY KEY (customerid, customertypeid);

ALTER TABLE sourcefuse_db_dbo.customerdemographics
ADD CONSTRAINT pk_customerdemographics_1365579903 PRIMARY KEY (customertypeid);

ALTER TABLE sourcefuse_db_dbo.customers
ADD CONSTRAINT pk_customers_357576312 PRIMARY KEY (customerid);

ALTER TABLE sourcefuse_db_dbo.employees
ADD CONSTRAINT ck_birthdate_293576084 CHECK (
(birthdate < clock_timestamp()));

ALTER TABLE sourcefuse_db_dbo.employees
ADD CONSTRAINT pk_employees_261575970 PRIMARY KEY (employeeid);

ALTER TABLE sourcefuse_db_dbo.employeeterritories
ADD CONSTRAINT pk_employeeterritories_1461580245 PRIMARY KEY (employeeid, territoryid);

ALTER TABLE sourcefuse_db_dbo.orders
ADD CONSTRAINT pk_orders_453576654 PRIMARY KEY (orderid);

ALTER TABLE sourcefuse_db_dbo.products
ADD CONSTRAINT ck_products_unitprice_677577452 CHECK (
(unitprice >= (0)));

ALTER TABLE sourcefuse_db_dbo.products
ADD CONSTRAINT ck_reorderlevel_693577509 CHECK (
(reorderlevel >= (0)));

ALTER TABLE sourcefuse_db_dbo.products
ADD CONSTRAINT ck_unitsinstock_709577566 CHECK (
(unitsinstock >= (0)));

ALTER TABLE sourcefuse_db_dbo.products
ADD CONSTRAINT ck_unitsonorder_725577623 CHECK (
(unitsonorder >= (0)));

ALTER TABLE sourcefuse_db_dbo.products
ADD CONSTRAINT pk_products_549576996 PRIMARY KEY (productid);

ALTER TABLE sourcefuse_db_dbo.region
ADD CONSTRAINT pk_region_1413580074 PRIMARY KEY (regionid);

ALTER TABLE sourcefuse_db_dbo.shippers
ADD CONSTRAINT pk_shippers_389576426 PRIMARY KEY (shipperid);

ALTER TABLE sourcefuse_db_dbo.suppliers
ADD CONSTRAINT pk_suppliers_421576540 PRIMARY KEY (supplierid);

ALTER TABLE sourcefuse_db_dbo.territories
ADD CONSTRAINT pk_territories_1429580131 PRIMARY KEY (territoryid);

-- ------------ Write CREATE-FOREIGN-KEY-CONSTRAINT-stage scripts -----------

ALTER TABLE sourcefuse_db_dbo."Order Details"
ADD CONSTRAINT fk_order_details_orders_821577965 FOREIGN KEY (orderid) 
REFERENCES sourcefuse_db_dbo.orders (orderid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sourcefuse_db_dbo."Order Details"
ADD CONSTRAINT fk_order_details_products_837578022 FOREIGN KEY (productid) 
REFERENCES sourcefuse_db_dbo.products (productid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sourcefuse_db_dbo.customercustomerdemo
ADD CONSTRAINT fk_customercustomerdemo_1381579960 FOREIGN KEY (customertypeid) 
REFERENCES sourcefuse_db_dbo.customerdemographics (customertypeid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sourcefuse_db_dbo.customercustomerdemo
ADD CONSTRAINT fk_customercustomerdemo_customers_1397580017 FOREIGN KEY (customerid) 
REFERENCES sourcefuse_db_dbo.customers (customerid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sourcefuse_db_dbo.employees
ADD CONSTRAINT fk_employees_employees_277576027 FOREIGN KEY (reportsto) 
REFERENCES sourcefuse_db_dbo.employees (employeeid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sourcefuse_db_dbo.employeeterritories
ADD CONSTRAINT fk_employeeterritories_employees_1477580302 FOREIGN KEY (employeeid) 
REFERENCES sourcefuse_db_dbo.employees (employeeid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sourcefuse_db_dbo.employeeterritories
ADD CONSTRAINT fk_employeeterritories_territories_1493580359 FOREIGN KEY (territoryid) 
REFERENCES sourcefuse_db_dbo.territories (territoryid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sourcefuse_db_dbo.orders
ADD CONSTRAINT fk_orders_customers_485576768 FOREIGN KEY (customerid) 
REFERENCES sourcefuse_db_dbo.customers (customerid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sourcefuse_db_dbo.orders
ADD CONSTRAINT fk_orders_employees_501576825 FOREIGN KEY (employeeid) 
REFERENCES sourcefuse_db_dbo.employees (employeeid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sourcefuse_db_dbo.orders
ADD CONSTRAINT fk_orders_shippers_517576882 FOREIGN KEY (shipvia) 
REFERENCES sourcefuse_db_dbo.shippers (shipperid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sourcefuse_db_dbo.products
ADD CONSTRAINT fk_products_categories_645577338 FOREIGN KEY (categoryid) 
REFERENCES sourcefuse_db_dbo.categories (categoryid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sourcefuse_db_dbo.products
ADD CONSTRAINT fk_products_suppliers_661577395 FOREIGN KEY (supplierid) 
REFERENCES sourcefuse_db_dbo.suppliers (supplierid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sourcefuse_db_dbo.territories
ADD CONSTRAINT fk_territories_region_1445580188 FOREIGN KEY (regionid) 
REFERENCES sourcefuse_db_dbo.region (regionid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

-- ------------ Write CREATE-PROCEDURE-stage scripts -----------

CREATE OR REPLACE PROCEDURE sourcefuse_db_dbo."Employee Sales by Country"(IN par_beginning_date TIMESTAMP WITHOUT TIME ZONE, IN par_ending_date TIMESTAMP WITHOUT TIME ZONE, INOUT p_refcur refcursor)
AS 
$BODY$
BEGIN
    OPEN p_refcur FOR
    SELECT
        employees.country, employees.lastname, employees.firstname, orders.shippeddate, orders.orderid, "Order Subtotals".subtotal AS saleamount
        FROM sourcefuse_db_dbo.employees
        INNER JOIN (sourcefuse_db_dbo.orders
        INNER JOIN sourcefuse_db_dbo."Order Subtotals"
            ON orders.orderid = "Order Subtotals".orderid)
            ON employees.employeeid = orders.ix_orders_employeeid
        WHERE orders.ix_orders_shippeddate BETWEEN par_Beginning_Date AND par_Ending_Date;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sourcefuse_db_dbo."Sales by Year"(IN par_beginning_date TIMESTAMP WITHOUT TIME ZONE, IN par_ending_date TIMESTAMP WITHOUT TIME ZONE, INOUT p_refcur refcursor)
AS 
$BODY$
BEGIN
    OPEN p_refcur FOR
    SELECT
        orders.shippeddate, orders.orderid, "Order Subtotals".subtotal, to_char(shippeddate::DATE, 'YYYY') AS year
        FROM sourcefuse_db_dbo.orders
        INNER JOIN sourcefuse_db_dbo."Order Subtotals"
            ON orders.orderid = "Order Subtotals".orderid
        WHERE orders.ix_orders_shippeddate BETWEEN par_Beginning_Date AND par_Ending_Date;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sourcefuse_db_dbo."Ten Most Expensive Products"(INOUT p_refcur refcursor)
AS 
$BODY$
BEGIN
    /*
    [7674 - Severity CRITICAL - DMS SC can't convert the ROWCOUNT clause of the SET statement. Convert your source code manually.]
    SET ROWCOUNT 10
    */
    OPEN p_refcur FOR
    SELECT
        products.productname AS tenmostexpensiveproducts, products.unitprice
        FROM sourcefuse_db_dbo.products
        ORDER BY products.unitprice DESC NULLS LAST;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sourcefuse_db_dbo.custorderhist(IN par_customerid CHAR, INOUT p_refcur refcursor)
AS 
$BODY$
BEGIN
    OPEN p_refcur FOR
    SELECT
        productname, SUM(quantity) AS total
        FROM sourcefuse_db_dbo.products AS p, sourcefuse_db_dbo."Order Details" AS od, sourcefuse_db_dbo.orders AS o, sourcefuse_db_dbo.customers AS c
        WHERE LOWER(c.customerid) = LOWER(par_CustomerID) AND LOWER(c.customerid) = LOWER(o.customerid) AND o.orderid = od.orderid AND od.productid = p.productid
        GROUP BY productname;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sourcefuse_db_dbo.custordersdetail(IN par_orderid INTEGER, INOUT p_refcur refcursor)
AS 
$BODY$
BEGIN
    OPEN p_refcur FOR
    SELECT
        productname, ROUND(od.unitprice, 2) AS unitprice, quantity, CAST (discount * 100 AS INTEGER) AS discount, ROUND(CAST (quantity * (1 - discount) * od.unitprice AS NUMERIC(19, 4)), 2) AS extendedprice
        FROM sourcefuse_db_dbo.products AS p, sourcefuse_db_dbo."Order Details" AS od
        WHERE od.productid = p.productid AND od.orderid = par_OrderID;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sourcefuse_db_dbo.custordersorders(IN par_customerid CHAR, INOUT p_refcur refcursor)
AS 
$BODY$
BEGIN
    OPEN p_refcur FOR
    SELECT
        orderid, orderdate, requireddate, shippeddate
        FROM sourcefuse_db_dbo.orders
        WHERE LOWER(customerid) = LOWER(par_CustomerID)
        ORDER BY orderid NULLS FIRST;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sourcefuse_db_dbo.salesbycategory(IN par_categoryname VARCHAR, IN par_ordyear VARCHAR DEFAULT '1998', INOUT p_refcur refcursor DEFAULT NULL)
AS 
$BODY$
BEGIN
    IF LOWER(par_OrdYear) != LOWER('1996') AND LOWER(par_OrdYear) != LOWER('1997') AND LOWER(par_OrdYear) != LOWER('1998') THEN
        SELECT
            '1998'
            INTO par_OrdYear;
    END IF;
    OPEN p_refcur FOR
    SELECT
        productname, ROUND(SUM(CAST (od.quantity * (1 - od.discount) * od.unitprice AS NUMERIC(14, 2))), 0) AS totalpurchase
        FROM sourcefuse_db_dbo."Order Details" AS od, sourcefuse_db_dbo.orders AS o, sourcefuse_db_dbo.products AS p, sourcefuse_db_dbo.categories AS c
        WHERE od.orderid = o.orderid AND od.productid = p.productid AND p.categoryid = c.categoryid AND LOWER(c.categoryname) = LOWER(par_CategoryName) AND LOWER(SUBSTR(aws_sqlserver_ext.conv_datetime_to_string('NVARCHAR(22)', 'DATETIME', o.orderdate, 111), 1, 4)) = LOWER(par_OrdYear)
        GROUP BY productname
        ORDER BY productname NULLS FIRST;
END;
$BODY$
LANGUAGE plpgsql;

