-- Create tables
CREATE TABLE Cart
(
    Cart_id VARCHAR(7) NOT NULL PRIMARY KEY
);

CREATE TABLE Customer
(
    Customer_id VARCHAR(6) NOT NULL PRIMARY KEY,
    c_pass VARCHAR(10) NOT NULL,
    Name VARCHAR(20) NOT NULL,
    Address VARCHAR(20) NOT NULL,
    Pincode INT NOT NULL,
    Phone_number_s INT NOT NULL,
    Cart_id VARCHAR(7) NOT NULL,
    FOREIGN KEY(Cart_id) REFERENCES Cart(Cart_id)
);

CREATE TABLE Seller
(
    Seller_id VARCHAR(6) NOT NULL PRIMARY KEY,
    s_pass VARCHAR(10) NOT NULL,
    Name VARCHAR(20) NOT NULL,
    Address VARCHAR(10) NOT NULL
);

CREATE TABLE Seller_Phone_num
(
    Phone_num INT NOT NULL,
    Seller_id VARCHAR(6) NOT NULL,
    PRIMARY KEY (Phone_num, Seller_id),
    FOREIGN KEY (Seller_id) REFERENCES Seller(Seller_id) ON DELETE CASCADE
);

CREATE TABLE Payment
(
    payment_id VARCHAR(7) NOT NULL PRIMARY KEY,
    payment_date DATE NOT NULL,
    Payment_type VARCHAR(10) NOT NULL,
    Customer_id VARCHAR(6) NOT NULL,
    Cart_id VARCHAR(7) NOT NULL,
    total_amount NUMERIC(6),
    FOREIGN KEY (Customer_id) REFERENCES Customer(Customer_id),
    FOREIGN KEY (Cart_id) REFERENCES Cart(Cart_id)
);

CREATE TABLE Product
(
    Product_id VARCHAR(7) NOT NULL PRIMARY KEY,
    Type VARCHAR(7) NOT NULL,
    Color VARCHAR(15) NOT NULL,
    P_Size VARCHAR(2) NOT NULL,
    Gender CHAR(1) NOT NULL,
    Commission INT NOT NULL,
    Cost INT NOT NULL,
    Quantity INT NOT NULL,
    Seller_id VARCHAR(6),
    FOREIGN KEY (Seller_id) REFERENCES Seller(Seller_id) ON DELETE SET NULL
);

CREATE TABLE Cart_item
(
    Quantity_wished INT NOT NULL,
    Date_Added DATE NOT NULL,
    Cart_id VARCHAR(7) NOT NULL,
    Product_id VARCHAR(7) NOT NULL,
    purchased VARCHAR(3) DEFAULT 'NO',
    PRIMARY KEY (Cart_id, Product_id),
    FOREIGN KEY (Cart_id) REFERENCES Cart(Cart_id),
    FOREIGN KEY (Product_id) REFERENCES Product(Product_id)
);

-- Functions
IF OBJECT_ID('numCartId', 'FN') IS NOT NULL
    DROP FUNCTION numCartId;
GO

CREATE FUNCTION numCartId(@cd VARCHAR(7))
RETURNS INT
AS
BEGIN
    DECLARE @total INT;

    SELECT @total = COUNT(*)
    FROM Cart_item
    WHERE Cart_id = @cd;

    RETURN @total;
END;
GO

-- Procedures
IF OBJECT_ID('cost_filter', 'P') IS NOT NULL
    DROP PROCEDURE cost_filter;
GO

CREATE PROCEDURE cost_filter
    @c INT,
    @t VARCHAR(7)
AS
BEGIN
    DECLARE @cs INT, @ty VARCHAR(7), @id VARCHAR(7);

    DECLARE cf CURSOR FOR
        SELECT Product_id, Cost, Type
        FROM Product
        WHERE Cost < @c AND Type = @t;

    OPEN cf;
    FETCH NEXT FROM cf INTO @id, @cs, @ty;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Product ' + @id + ' has cost ' + CAST(@cs AS VARCHAR(10)) + ' and the type is ' + @ty;
        FETCH NEXT FROM cf INTO @id, @cs, @ty;
    END;

    CLOSE cf;
    DEALLOCATE cf;
END;
GO

IF OBJECT_ID('prod_details', 'P') IS NOT NULL
    DROP PROCEDURE prod_details;
GO

CREATE PROCEDURE prod_details
    @p_id VARCHAR(7)
AS
BEGIN
    DECLARE @quan INT;

    SELECT @quan = Quantity
    FROM Product
    WHERE Product_id = @p_id;

    IF @@ROWCOUNT > 0
        PRINT 'Quantity of Product ' + @p_id + ' is ' + CAST(@quan AS VARCHAR(10));
    ELSE
        PRINT 'Sorry, no such product exists!';
END;
GO

-- Triggers
IF OBJECT_ID('before_customer', 'TR') IS NOT NULL
    DROP TRIGGER before_customer;
GO

CREATE TRIGGER before_customer
ON Customer
AFTER INSERT
AS
BEGIN
    DECLARE @c VARCHAR(7), @n INT;

    SELECT @c = Cart_id FROM inserted;
    SELECT @n = dbo.numCartId(@c);

    IF @n > 0
    BEGIN
        PRINT 'Sorry, cart already exists for this customer.';
    END
    ELSE
    BEGIN
        INSERT INTO Cart (Cart_id) VALUES (@c);
    END
END;
GO


-- Triggers
IF OBJECT_ID('before_customer', 'TR') IS NOT NULL
    DROP TRIGGER before_customer;
GO

CREATE TRIGGER before_customer
ON Customer
AFTER INSERT
AS
BEGIN
    DECLARE @c VARCHAR(7), @n INT;

    SELECT @c = Cart_id FROM inserted;
    SELECT @n = dbo.numCartId(@c);

    IF @n > 0
    BEGIN
        PRINT 'Sorry, cart already exists for this customer.';
    END
    ELSE
    BEGIN
        INSERT INTO Cart (Cart_id) VALUES (@c);
    END
END;
GO
