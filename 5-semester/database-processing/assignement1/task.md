Task Description:

You are required to assume the role of a Database Developer for a ticketing and event management company. Your responsibility is to design and implement the database structure for managing events, ticket types, customer orders, and system auditing.

Your solution will consist of three SQL scripts:

    A DDL file that defines all database objects.
    A DML file that inserts realistic test data.
    A PL/SQL triggers file that enforces business rules and auditing logic.

The complete solution must be tested in Oracle Live SQL and submitted as three separate files.

Requirements:

Your database solution must include the following elements:

1. Database Schema (DDL Script)

   Create tables for managing events, ticket types, customer orders, order lines, and an audit log.
   Define appropriate primary keys, foreign keys, data types, and constraints.
   Ensure referential integrity between related entities (e.g., orders linked to events and ticket types).
   Use meaningful column names and comments to describe the purpose of each table.

2. Sample Data (DML Script)

   Insert at least two events, each with multiple ticket types and defined capacities.
   Insert at least three orders with various ticket line items that represent valid and boundary cases (e.g., near-capacity, insufficient capacity).
   Include data that can be used to test both valid and invalid operations triggered by your business rules.

3. Trigger Logic (PL/SQL Script)

   Implement database triggers to maintain consistency and enforce business rules such as:
   Preventing the sale of tickets that exceed the available capacity.
   Automatically calculating totals for order lines and overall order amounts.
   Logging significant changes (insert, update, delete) into an audit table.
   Triggers must operate correctly on multi-row operations.
   Include clear comments explaining the purpose, timing, and scope of each trigger.
   Do not use commits or autonomous transactions inside triggers.

4. Audit Logging

   Design a general-purpose audit table to record who made a change, when it occurred, which table was affected, and the action performed.
   All triggers must insert relevant details into this audit table when DML occurs on key entities.

Submission Guidelines:

    Prepare and submit the following three files:
        ticketing_ddl.sql — contains only table creation statements.
        ticketing_dml.sql — contains only insert statements.
        ticketing_triggers.sql — contains only trigger definitions.
    Each file must include a header with your full name, date, and a short description.
    All scripts must be runnable in Oracle Live SQL in the order DDL → DML → Triggers.
    All objects should compile successfully without manual edits.
    Include brief inline comments explaining design choices and assumptions.
    Each file should be self-contained and readable.

Assessment Criteria:

Your submission will be graded according to the following criteria:

Criterion

Description

Weight

Schema Design and Completeness

Tables, constraints, and relationships are logically designed and clearly defined.

25%

Trigger Functionality and Accuracy

Triggers correctly enforce business rules and maintain derived data.

25%

Audit Logging Implementation

Audit table design and trigger-based logging are complete and accurate.

20%

Data and Test Coverage

Inserted data supports verification of both valid and invalid cases.

15%

Professionalism and Readability

Code is well-organized, clearly commented, and free of syntax or formatting issues.

15%

Additional Notes:

· You must design the schema yourself; do not use prebuilt examples.

· Keep the structure compact but realistic to demonstrate understanding of relational design.

· Ensure your DML data provides enough variation to test all trigger conditions.

· Triggers must handle both insert and update scenarios correctly.

· Avoid any code that commits transactions within trigger bodies.
