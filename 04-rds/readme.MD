# RDS Configurations
* As we are using AWS RDS DB, We should configure tables and users. Use Bastion as Client and COnfigure Manually. 
* Note: Bastion should have accesd to RDS MySQL. SO need to allow mysql_sg form bastion port 3306.
* mysql server should install in Bastion to configure below tables and schema, etc.

```
mysql -h <rds-endpoint_address> -u root -p<DB_Password>
```
EG:1
``` 
mysql -h expense-dev.czn6yzxlcsiv.us-east-1.rds.amazonaws.com -u root -pExpenseApp1
```
Eg:2
```
mysql -h mysql-dev.telugudevops.online -u root -pExpenseApp1
```

```
USE transactions;
```
```
CREATE TABLE IF NOT EXISTS transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    amount INT,
    description VARCHAR(255)
);
```

```
CREATE USER IF NOT EXISTS 'expense'@'%' IDENTIFIED BY 'ExpenseApp@1';

```

```
GRANT ALL ON transactions.* TO 'expense'@'%';
```

```
FLUSH PRIVILEGES;
```
