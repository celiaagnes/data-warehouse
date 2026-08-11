# Data Dictionnary for Gold layer

## Overview

The Gold-layer is the business-level data representation, structured to report analytical and use cases. 
It consists of **dimension** and **fact tables** for specific business metrics.

### 1. gold.dim_customers

- **Purpose** : Stores customers details with their demographic and geographic details.
- **Columns** :

| Column name | Data Type | Description |
|---|---|---:|
| customer_key | INT | Surrogate key uniquely identifying each customer record in the dimension table.|
| costumer_id | INT | Unique numerical identifier assigned to each costumer. |
| costumer_number | NVARCHAT(50) | Alphanumeric identifier representing the customer, used for tracking and referencing.|  
| first_name | NVARCHAT(50) |The customer's first name, as recorded in the system. | 
| last_name | NVARCHAT(50) |   The customer's last name or family name.| 
| country | NVARCHAT(50) | The country of residence for the customer (example 'France'). | 
| marital_status | NVARCHAT(50) |The marital status of the customer (example 'Married', 'Single'). | 
| gender | NVARCHAT(50) |   The gender of the customer (example 'Male', 'Female', 'n/a').| 
| birth_date | DATE | The date of birth of the customer, formatted as YYYY-MM-DD (e.g., 1971-10-06). | 
| create_date | DATE | The date and time when the customer record was created in the system. | 


### 2. gold.dim_products

- **Purpose** : Stores products details.
- **Columns** :

| Column name | Data Type | Description |
|---|---|---:|
| product_key | INT | Surrogate key uniquely identifying each product record in the dimension table |
| product_id | INT | Unique numerical identifier assigned to each costumer. |
| product_number | NVARCHAT(50) | A structured alphanumeric code representing the product, often used for categorization or inventory. |  
| product_name | NVARCHAT(50) | Descriptive name of the product, including key details such as type, color, and size. | 
| category_id | INT | A unique identifier for the product's category, linking to its high-level classification. | 
| category | NVARCHAT(50) | The broader classification of the product (e.g., Bikes, Components) to group related items. | 
| subcategory | NVARCHAT(50) | A more detailed classification of the product within the category, such as product type. | 
| maintenance | NVARCHAT(50) | Indicates whether the product requires maintenance (example 'Yes', 'No'). | 
| cost | INT | The cost or base price of the product, measured in monetary units. | 
| product_line | NVARCHAT(50) | The specific product line or series to which the product belongs (example Road, Mountain). | 
| date_start | DATE | The date when the product became available for sale or use, stored in. | 


### 3. gold.fact_sales

- **Purpose** : Stores sales details and associates an order with a product and a costumer.
- **Columns** :

| Column name | Data Type | Description |
|---|---|---:|
| order_number | INT | A unique alphanumeric identifier for each sales order (example 'SO54496').  |
| product_key | INT | Surrogate key linking the order to the product dimension table. |
| costumer_key | NVARCHAT(50) | Surrogate key linking the order to the customer dimension table. |  
| sales_amount | INT |  The total monetary value of the sale for the line item, in whole currency units (example 25). | 
| quantity | INT |   The number of units of the product ordered for the line item (example 1). | 
| price | INT |  The price per unit of the product for the line item, in whole currency units (example 25). | 
| order_date | DATE | The date when the order was placed. | 
| ship_date | DATE | The date when the order was shipped to the customer. | 
| due_date | DATE | 1The date when the order payment was due. | 