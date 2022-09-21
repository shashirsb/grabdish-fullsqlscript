---------------------------
--  schema_create_aq.sql --
---------------------------

-- liquibase formatted sql

-- changeset gotsysdba:1 context:1db endDelimiter:/
DECLARE
  L_USER	VARCHAR2(255);
BEGIN
  SELECT USERNAME INTO L_USER FROM DBA_USERS WHERE USERNAME='AQ';
EXCEPTION WHEN NO_DATA_FOUND THEN
  execute immediate 'CREATE USER "AQ" IDENTIFIED BY "MyDB@12345678"';
END;
/

ALTER USER "AQ" GRANT CONNECT THROUGH ADMIN
/

GRANT UNLIMITED TABLESPACE TO "AQ"
/

GRANT CONNECT, RESOURCE TO "AQ"
/

GRANT AQ_USER_ROLE TO "AQ"
/

GRANT EXECUTE ON SYS.DBMS_AQADM TO "AQ"
/

GRANT EXECUTE ON SYS.DBMS_AQ TO "AQ"
/

--rollback drop user "AQ" cascade;



------------------------------
--  schema_create_order.sql --
------------------------------



-- liquibase formatted sql

-- changeset gotsysdba:1 context:1db endDelimiter:/
DECLARE
  L_USER	VARCHAR2(255);
BEGIN
  SELECT USERNAME INTO L_USER FROM DBA_USERS WHERE USERNAME='ORDERUSER';
EXCEPTION WHEN NO_DATA_FOUND THEN
  execute immediate 'CREATE USER "ORDERUSER" IDENTIFIED BY "MyDB@12345678"';
END;
/

ALTER USER "ORDERUSER" GRANT CONNECT THROUGH ADMIN
/

GRANT UNLIMITED TABLESPACE TO "ORDERUSER"
/

GRANT CONNECT, RESOURCE TO "ORDERUSER"
/

GRANT AQ_USER_ROLE TO "ORDERUSER"
/

GRANT EXECUTE ON SYS.DBMS_AQ TO "ORDERUSER"
/

GRANT SODA_APP TO "ORDERUSER"
/

--THIS IS ALL WE WANT BUT TABLE HASN'T BEEN CREATED YET... GRANT SELECT ON AQ.ORDERQUEUETABLE TO $ORDER_USER;
GRANT SELECT ANY TABLE TO "ORDERUSER"
/

GRANT SELECT ON GV$SESSION TO "ORDERUSER"
/

GRANT SELECT ON V$DIAG_ALERT_EXT TO "ORDERUSER"
/

GRANT SELECT ON DBA_QUEUE_SCHEDULES TO "ORDERUSER"
/

--rollback drop user "ORDERUSER" cascade;


----------------------------------
--  schema_create_inventory.sql --
----------------------------------


-- liquibase formatted sql

-- changeset gotsysdba:1 context:1db endDelimiter:/
DECLARE
  L_USER	VARCHAR2(255);
BEGIN
  SELECT USERNAME INTO L_USER FROM DBA_USERS WHERE USERNAME='INVENTORYUSER';
EXCEPTION WHEN NO_DATA_FOUND THEN
  execute immediate 'CREATE USER "INVENTORYUSER" IDENTIFIED BY "MyDB@12345678"';
END;
/

ALTER USER "INVENTORYUSER" GRANT CONNECT THROUGH ADMIN
/

GRANT UNLIMITED TABLESPACE TO "INVENTORYUSER"
/

GRANT CONNECT, RESOURCE TO "INVENTORYUSER"
/

GRANT AQ_USER_ROLE TO "INVENTORYUSER"
/

GRANT EXECUTE ON SYS.DBMS_AQ TO "INVENTORYUSER"
/

-- FOR INVENTORY-SPRINGBOOT DEPLOYMENT
GRANT AQ_ADMINISTRATOR_ROLE TO "INVENTORYUSER"
/

GRANT EXECUTE ON SYS.DBMS_AQADM TO "INVENTORYUSER"
/

-- FOR INVENTORY-PLSQL DEPLOYMENT
GRANT CREATE JOB TO "INVENTORYUSER"
/

GRANT EXECUTE ON SYS.DBMS_SCHEDULER TO "INVENTORYUSER"
/

--THIS IS ALL WE WANT BUT TABLE HASN'T BEEN CREATED YET... GRANT SELECT ON AQ.INVENTORYQUEUETABLE TO $INVENTORY_USER;
GRANT SELECT ANY TABLE TO "INVENTORYUSER"
/

GRANT SELECT ON GV$SESSION TO "INVENTORYUSER"
/

GRANT SELECT ON V$DIAG_ALERT_EXT TO "INVENTORYUSER"
/

GRANT SELECT ON DBA_QUEUE_SCHEDULES TO "INVENTORYUSER"
/

--rollback drop user "INVENTORYUSER" cascade;



----------------------------------
--  queues_create_classic.sql   --
----------------------------------

-- liquibase formatted sql

-- changeset gotsysdba:1 labels:classic context:1db endDelimiter:/ rollbackEndDelimiter:/
BEGIN
  DBMS_AQADM.CREATE_QUEUE_TABLE (
    QUEUE_TABLE        => 'ORDERQUEUETABLE',
    QUEUE_PAYLOAD_TYPE => 'SYS.AQ$_JMS_TEXT_MESSAGE',
    MULTIPLE_CONSUMERS => true,
    COMPATIBLE         => '8.1'
  );

  DBMS_AQADM.CREATE_QUEUE_TABLE (
    QUEUE_TABLE        => 'INVENTORYQUEUETABLE',
    QUEUE_PAYLOAD_TYPE => 'SYS.AQ$_JMS_TEXT_MESSAGE',
    MULTIPLE_CONSUMERS => true,
    COMPATIBLE         => '8.1'
  );

  DBMS_AQADM.CREATE_QUEUE (
    QUEUE_NAME         => 'ORDERQUEUE',
    QUEUE_TABLE        => 'ORDERQUEUETABLE'
  );

  DBMS_AQADM.CREATE_QUEUE (
    QUEUE_NAME         => 'INVENTORYQUEUE',
    QUEUE_TABLE        => 'INVENTORYQUEUETABLE'
  );

  DBMS_AQADM.START_QUEUE (
    QUEUE_NAME         => 'ORDERQUEUE'
  );

  DBMS_AQADM.START_QUEUE (
    QUEUE_NAME         => 'INVENTORYQUEUE'
  );
END;
/

--rollback BEGIN
--rollback     DBMS_AQADM.STOP_QUEUE (
--rollback         QUEUE_NAME => 'ORDERQUEUE'
--rollback     );
--rollback     DBMS_AQADM.STOP_QUEUE (
--rollback         QUEUE_NAME => 'INVENTORYQUEUE'
--rollback     );
--rollback     DBMS_AQADM.DROP_QUEUE (
--rollback         QUEUE_NAME => 'ORDERQUEUE'
--rollback     );
--rollback     DBMS_AQADM.DROP_QUEUE (
--rollback         QUEUE_NAME => 'INVENTORYQUEUE'
--rollback     );
--rollback     DBMS_AQADM.DROP_QUEUE_TABLE (
--rollback         QUEUE_TABLE => 'ORDERQUEUETABLE'
--rollback     );
--rollback     DBMS_AQADM.DROP_QUEUE_TABLE (
--rollback         QUEUE_TABLE => 'INVENTORYQUEUETABLE'
--rollback     );
--rollback END;
--rollback /



----------------------------------
--  queues_privileges.sql       --
----------------------------------


-- liquibase formatted sql

-- changeset gotsysdba:1 context:1db endDelimiter:/
BEGIN
  DBMS_AQADM.grant_queue_privilege (
    privilege    => 'ENQUEUE',
    queue_name   => 'ORDERQUEUE',
    grantee      => 'ORDERUSER',
    grant_option =>  FALSE
  );

  DBMS_AQADM.grant_queue_privilege (
    privilege    => 'DEQUEUE',
    queue_name   => 'INVENTORYQUEUE',
    grantee      => 'ORDERUSER',
    grant_option => FALSE
  );

  DBMS_AQADM.grant_queue_privilege (
    privilege    => 'ENQUEUE',
    queue_name   => 'INVENTORYQUEUE',
    grantee      => 'INVENTORYUSER',
    grant_option =>  FALSE
  );

  DBMS_AQADM.grant_queue_privilege (
    privilege    => 'DEQUEUE',
    queue_name   => 'ORDERQUEUE',
    grantee      => 'INVENTORYUSER',
    grant_option =>  FALSE
  );

  DBMS_AQADM.add_subscriber(
    queue_name   => 'ORDERQUEUE',
    subscriber   => sys.aq$_agent('inventory_service',NULL,NULL)
  );

  DBMS_AQADM.add_subscriber(
    queue_name   => 'INVENTORYQUEUE',
    subscriber   => sys.aq$_agent('order_service',NULL,NULL)
  );
END;
/

--rollback SELECT 'N/A' FROM DUAL;



----------------------------------
--  objects_inventory.sql       --
----------------------------------



-- liquibase formatted sql

-- changeset gotsysdba:1 context:1db endDelimiter:/
CREATE TABLE INVENTORYUSER.INVENTORY (
  INVENTORYID       VARCHAR(16) PRIMARY KEY NOT NULL,
  INVENTORYLOCATION VARCHAR(32),
  INVENTORYCOUNT    INTEGER CONSTRAINT POSITIVE_INVENTORY CHECK (INVENTORYCOUNT >= 0)
)
/
INSERT INTO INVENTORYUSER.INVENTORY VALUES ('sushi', '1468 WEBSTER ST,San Francisco,CA', 0)
/
INSERT INTO INVENTORYUSER.INVENTORY VALUES ('pizza', '1469 WEBSTER ST,San Francisco,CA', 0)
/
INSERT INTO INVENTORYUSER.INVENTORY VALUES ('burger', '1470 WEBSTER ST,San Francisco,CA', 0)
/

CREATE OR REPLACE PROCEDURE INVENTORYUSER.dequeueOrderMessage (
    p_orderInfo OUT VARCHAR2
) IS
  dequeue_options       DBMS_AQ.DEQUEUE_OPTIONS_T;
  message_properties    DBMS_AQ.MESSAGE_PROPERTIES_T;
  message_handle        RAW(16);
  message               SYS.AQ$_JMS_TEXT_MESSAGE;
  no_messages           EXCEPTION;
  pragma                EXCEPTION_INIT(no_messages, -25228);      
BEGIN
  --  dequeue_options.wait := dbms_aq.NO_WAIT;
  dequeue_options.wait          := SYS.DBMS_AQ.FOREVER;
  dequeue_options.consumer_name := 'inventory_service';
  dequeue_options.navigation    := SYS.DBMS_AQ.FIRST_MESSAGE;

  -- dequeue_options.navigation := dbms_aq.FIRST_MESSAGE;
  -- dequeue_options.dequeue_mode := dbms_aq.LOCKED;

  DBMS_AQ.DEQUEUE(
    queue_name         => 'AQ.ORDERQUEUE',
    dequeue_options    => dequeue_options,
    message_properties => message_properties,
    payload            => message,
    msgid              => message_handle
  );
  -- COMMIT;

  --  p_action := message.get_string_property('action');
  --  p_orderid := message.get_int_property('orderid');
  p_orderInfo := message.text_vc;
  --  message.get_text(p_orderInfo);
  EXCEPTION
    WHEN no_messages THEN
      BEGIN
        p_orderInfo := '';
      END;
    WHEN OTHERS THEN
      RAISE;
END;
/

CREATE OR REPLACE PROCEDURE INVENTORYUSER.checkInventoryReturnLocation (
   p_inventoryId IN VARCHAR2
  ,p_inventorylocation OUT varchar2
) IS
BEGIN
  update INVENTORYUSER.INVENTORY 
     set inventorycount = inventorycount - 1 
   where inventoryid = p_inventoryId and inventorycount > 0 
   returning inventorylocation into p_inventorylocation;

  dbms_output.put_line('p_inventorylocation');
  dbms_output.put_line(p_inventorylocation);
END;
/

CREATE OR REPLACE PROCEDURE INVENTORYUSER.enqueueInventoryMessage (
  p_inventoryInfo IN VARCHAR2
) IS
  enqueue_options     DBMS_AQ.enqueue_options_t;
  message_properties  DBMS_AQ.message_properties_t;
  message_handle      RAW(16);
  message             SYS.AQ$_JMS_TEXT_MESSAGE;
BEGIN
  message := SYS.AQ$_JMS_TEXT_MESSAGE.construct;
  -- message.text_vc := p_inventoryInfo;
  message.set_text(p_inventoryInfo);
  -- message.set_string_property('action', p_action);
  -- message.set_int_property('orderid', p_orderid);

  DBMS_AQ.ENQUEUE(
    queue_name => 'AQ.INVENTORYQUEUE',
    enqueue_options    => enqueue_options,
    message_properties => message_properties,
    payload            => message,
    msgid              => message_handle
  );
END;
/

CREATE OR REPLACE PROCEDURE INVENTORYUSER.dequeue_order_message (
   in_wait_option     IN BINARY_INTEGER
  ,out_order_message OUT VARCHAR2
) IS
  dequeue_options       dbms_aq.dequeue_options_t;
  message_properties    dbms_aq.message_properties_t;
  message_handle        RAW(16);
  message               SYS.AQ$_JMS_TEXT_MESSAGE;
  no_messages           EXCEPTION;
  pragma                exception_init(no_messages, -25228); 
BEGIN
  CASE in_wait_option
    WHEN 0 THEN
      dequeue_options.wait := dbms_aq.NO_WAIT;
    WHEN -1 THEN
      dequeue_options.wait := dbms_aq.FOREVER;
    ELSE
      dequeue_options.wait := in_wait_option;
  END CASE;

  dequeue_options.consumer_name := 'INVENTORY_SERVICE';
  dequeue_options.navigation    := dbms_aq.FIRST_MESSAGE;  -- Required for TEQ

  DBMS_AQ.DEQUEUE(
    queue_name         => 'AQ.ORDERQUEUE',
    dequeue_options    => dequeue_options,
    message_properties => message_properties,
    payload            => message,
    msgid              => message_handle
  );
  out_order_message := message.text_vc;

EXCEPTION
  WHEN no_messages THEN
    out_order_message := '';
  WHEN OTHERS THEN
    RAISE;
END;
/

CREATE OR REPLACE PROCEDURE INVENTORYUSER.enqueue_inventory_message (
  in_inventory_message IN VARCHAR2
) IS
   enqueue_options     dbms_aq.enqueue_options_t;
   message_properties  dbms_aq.message_properties_t;
   message_handle      RAW(16);
   message             SYS.AQ$_JMS_TEXT_MESSAGE;
BEGIN
  message := SYS.AQ$_JMS_TEXT_MESSAGE.construct;
  message.set_text(in_inventory_message);

  dbms_aq.ENQUEUE (
    queue_name         => 'AQ.INVENTORYQUEUE',
    enqueue_options    => enqueue_options,
    message_properties => message_properties,
    payload            => message,
    msgid              => message_handle
  );
END;
/

CREATE OR REPLACE PROCEDURE INVENTORYUSER.check_inventory (
   in_inventory_id         IN VARCHAR2
  ,out_inventory_location OUT VARCHAR2)
IS
BEGIN
  update INVENTORYUSER.INVENTORY set inventorycount = inventorycount - 1 
    where inventoryid = in_inventory_id and inventorycount > 0 
    returning inventorylocation into out_inventory_location;
  if sql%rowcount = 0 then
    out_inventory_location := 'inventorydoesnotexist';
  end if;
END;
/

CREATE OR REPLACE PROCEDURE INVENTORYUSER.inventory_service
IS
  order_message  VARCHAR2(32767);
  order_inv_id   VARCHAR2(16);
  order_inv_loc  VARCHAR2(32);
  order_json     JSON_OBJECT_T;
  inventory_json JSON_OBJECT_T;
BEGIN
  LOOP
    -- Wait for and dequeue the next order message
    dequeue_order_message(
      in_wait_option    => -1,  -- Wait forever
      out_order_message => order_message
    );

    -- Parse the order message
    order_json := JSON_OBJECT_T.parse(order_message);
    order_inv_id := order_json.get_string('itemid');

    -- Check the inventory
    check_inventory(
      in_inventory_id        => order_inv_id,
      out_inventory_location => order_inv_loc
    );
      
    -- Construct the inventory message
    inventory_json := new JSON_OBJECT_T;
    inventory_json.put('orderid',           order_json.get_string('orderid'));
    inventory_json.put('itemid',            order_inv_id);
    inventory_json.put('inventorylocation', order_inv_loc);
    inventory_json.put('suggestiveSale',    'beer');

    -- Send the inventory message
    enqueue_inventory_message(
      in_inventory_message   => inventory_json.to_string() 
    );

    -- commit
    commit;
  END LOOP;
END;
/

--rollback DROP PROCEDURE INVENTORYUSER.inventory_service;
--rollback DROP PROCEDURE INVENTORYUSER.check_inventory;
--rollback DROP PROCEDURE INVENTORYUSER.enqueue_inventory_message;
--rollback DROP PROCEDURE INVENTORYUSER.dequeue_order_message;
--rollback DROP PROCEDURE INVENTORYUSER.enqueueInventoryMessage;
--rollback DROP PROCEDURE INVENTORYUSER.checkInventoryReturnLocation;
--rollback DROP PROCEDURE INVENTORYUSER.dequeueOrderMessage;
--rollback DROP TABLE INVENTORYUSER.INVENTORY;




----------------------------------
--  objects_order.sql           --
----------------------------------



-- liquibase formatted sql

-- changeset gotsysdba:1 context:1db endDelimiter:/

-- Insert order
CREATE OR REPLACE PROCEDURE ORDERUSER.insert_order (
   in_order_id IN VARCHAR2
  ,in_order    IN VARCHAR2
) AUTHID CURRENT_USER IS
  order_doc             SODA_DOCUMENT_T;
  collection            SODA_COLLECTION_T;
  status                NUMBER;
  collection_name       CONSTANT VARCHAR2(20) := 'orderscollection';
  collection_metadata   CONSTANT VARCHAR2(4000) := '{"keyColumn" : {"assignmentMethod": "CLIENT"}}';
BEGIN
  -- Write the order object
  collection := DBMS_SODA.open_collection(collection_name);
  IF collection IS NULL THEN
    collection := DBMS_SODA.create_collection(collection_name, collection_metadata);
  END IF;

  order_doc := SODA_DOCUMENT_T(in_order_id, b_content => utl_raw.cast_to_raw(in_order));
  status := collection.insert_one(order_doc);
END;
/

-- Enqueue order message
CREATE OR REPLACE PROCEDURE ORDERUSER.enqueue_order_message (
  in_order_message IN VARCHAR2
) AUTHID CURRENT_USER IS
   enqueue_options     dbms_aq.enqueue_options_t;
   message_properties  dbms_aq.message_properties_t;
   message_handle      RAW(16);
   message             SYS.AQ$_JMS_TEXT_MESSAGE;
BEGIN
  message := SYS.AQ$_JMS_TEXT_MESSAGE.construct;
  message.set_text(in_order_message);

  dbms_aq.ENQUEUE(
    queue_name         => 'ORDERUSER.ORDERQUEUE',
    enqueue_options    => enqueue_options,
    message_properties => message_properties,
    payload            => message,
    msgid              => message_handle
  );
END;
/


-- place order microserice (GET)
-- Example: ../ords/orderuser/placeorder/order?orderId=66&orderItem=sushi&deliverTo=Redwood
CREATE OR REPLACE PROCEDURE ORDERUSER.place_order (
  orderid           IN varchar2,
  itemid            IN varchar2,
  deliverylocation  IN varchar2
) AUTHID CURRENT_USER IS
  order_json            JSON_OBJECT_T;
BEGIN
  -- Construct the order object
  order_json := new JSON_OBJECT_T;
  order_json.put('orderid', orderid);
  order_json.put('itemid',  itemid);
  order_json.put('deliverylocation', deliverylocation);
  order_json.put('status', 'Pending');
  order_json.put('inventoryLocation', '');
  order_json.put('suggestiveSale', '');

  -- Insert the order object
  insert_order(orderid, order_json.to_string());

  -- Send the order message
  enqueue_order_message(order_json.to_string());

  -- Commit
  commit;

  HTP.print(order_json.to_string());

  EXCEPTION
    WHEN OTHERS THEN
      HTP.print(SQLERRM);

END;
/

-- frontend place order (POST)
CREATE OR REPLACE PROCEDURE ORDERUSER.frontend_place_order (
  serviceName IN varchar2,
  commandName IN varchar2,
  orderId     IN varchar2,
  orderItem   IN varchar2,
  deliverTo   IN varchar2
) AUTHID CURRENT_USER IS
BEGIN
  place_order (
    orderid          => orderId,
    itemid           => orderItem,
    deliverylocation => deliverTo
  );
END;
/

-- Place Order using MLE JavaScript
-- Note this was carried over but is invalid... can't use reserved work "ORDER"
-- also the first line IS ctx DBMS_MLE is not valid... NULL'ing out.
CREATE OR REPLACE PROCEDURE ORDERUSER.place_order_js (
  orderid           IN varchar2,
  itemid            IN varchar2,
  deliverylocation  IN varchar2
) AUTHID CURRENT_USER IS
  --  ctx DBMS_MLE.context_handle_t := DBMS_MLE.create_context();
  --  order VARCHAR2(4000);
  --  js_code clob := q'~
  --   var oracledb = require("mle-js-oracledb");
  --   var bindings = require("mle-js-bindings");
  --   conn = oracledb.defaultConnection();

  --   // Construct the order object
  --   const order = {
  --     orderid: bindings.importValue("orderid"),
  --     itemid: bindings.importValue("itemid"),
  --     deliverylocation: bindings.importValue("deliverylocation"),
  --     status: "Pending",
  --     inventoryLocation: "",
  --     suggestiveSale: ""
  --   }
    
  --   // Insert the order object
  --   insert_order(conn, order);

  --   // Send the order message
  --   enqueue_order_message(conn, order);

  --   // Commit
  --   conn.commit;

  --   // Output order
  --   bindings.exportValue("order", order.stringify());

  --   function insert_order(conn, order) {
  --       conn.execute( "BEGIN insert_order(:1, :2); END;", [order.orderid, order.stringify()]);
  --   }

  --   function enqueue_order_message(conn, order) {
  --       conn.execute( "BEGIN enqueue_order_message(:1); END;", [order.stringify()]);
  --   }
  --  ~';
BEGIN
  NULL;
  -- -- Pass variables to JavaScript
  -- dbms_mle.export_to_mle(ctx, 'orderid', orderid); 
  -- dbms_mle.export_to_mle(ctx, 'itemid', itemid); 
  -- dbms_mle.export_to_mle(ctx, 'deliverylocation', deliverylocation); 

  -- -- Execute JavaScript
  -- DBMS_MLE.eval(ctx, 'JAVASCRIPT', js_code);
  -- DBMS_MLE.import_from_mle(ctx, 'order', order);
  -- DBMS_MLE.drop_context(ctx);

  -- HTP.print(order);
-- EXCEPTION
--   WHEN others THEN
--     dbms_mle.drop_context(ctx);
--     HTP.print(SQLERRM);
END;
/

--rollback DROP PROCEDURE ORDERUSER.place_order_js;
--rollback DROP PROCEDURE ORDERUSER.enqueue_order_message;
--rollback DROP PROCEDURE ORDERUSER.insert_order;
--rollback DROP PROCEDURE ORDERUSER.place_order;
--rollback DROP PROCEDURE ORDERUSER.frontend_place_order;

