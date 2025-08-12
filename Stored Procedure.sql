Store Procedure
create a function as soon as the product is sold the the same quantity should reduced from inventory table
After adding any sales records it should update the stock in the inventory table based on the product and qty purchased

/*
--In this stored procedure, we will take the parameter, declare a variable, and input the required data into the variable using SELECT INTO and  
Using INSERT INTO, we will insert the variables and parameters into the order_items and orders tables. We will reduce the quantity from the Inventory Table 
*/

CREATE OR REPLACE PROCEDURE first_procedure(
p_order_id INT,
p_customer_id INT,
p_seller_id INT,
p_order_status VARCHAR(100),
p_order_item_id INT,
p_product_id INT,
p_quantity INT
)
LANGUAGE plpgsql
AS $$
DECLARE --Variable declaration with their type 
   v_item_price FLOAT; 
   v_total_sales FLOAT;
   v_stock INT;
BEGIN 

  SELECT price INTO v_item_price FROM product --Assigning the price to a variable v_item_price for the provided product_id 
  WHERE product_id = p_product_id;

  SELECT (v_item_price*p_quantity) INTO v_total_sales FROM order_items --for the parameter product_id, calculating the total_sales of the product by multiplying the product with the total_quantity and assigning the value to the variable: v_total_sales 
  WHERE product_id = p_product_id;

  SELECT stock INTO v_stock FROM inventory
  where product_id=p_product_id; --Since the stock is one value per row SUM(stock)=stock, assigning the stock quantity to the variable v_stock, specific to the required product _id passed as a parameter

  IF v_stock>=p_quantity  -- the below could be performed only when the stock is greater than the order quantity
  THEN

  UPDATE inventory   -- updating the inventory with the reduced stocks of the order 
  SET stock = stock - p_quantity;
  
  INSERT INTO orders(order_id,order_date,customer_id, seller_id) --Inserting the values into the orders table 
  VALUES(p_order_id,CURRENT_DATE,p_customer_id,p_seller_id);

  INSERT INTO order_items(order_item_id,order_id,product_id,quantity,price_per_unit,total_sales) --Inserting values into the order_items table 
  VALUES (p_order_item_id,p_order_id,p_product_id,p_quantity,v_item_price,v_total_sales);

  RAISE NOTICE 'update is sucessfull'; --Once the IF condition satisfied and all the process is completed finely

  ELSE
  RAISE NOTICE 'NOT enough inventory';   --if the quantity is not enough to fulfill the order or incomplete order

END IF;
END$$;

--Calling the procedure
CALL first_procedure (220010,751,12,'Completed',220010,1,4);
