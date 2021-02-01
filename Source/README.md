# Setup and Run

---

## Getting Started

1. Execute **RunDW.sql** with SQL Server Database engine , after the completion of execution , we will have all the procedures and tables related to data warehouse and staging area
2. To fill the staging area and data ware house facts and dimensions and related tables , run the following command :
   **`EXECUTE FILL_DATA_WAREHOUSE 'yyyy-mm-dd' , 0`**
3. You can give the preceding procedure the parameter **0 o 1** indicating that wheter it is First Load or Normal Mode , **1 for First Load , 0 for Normal Mode**
