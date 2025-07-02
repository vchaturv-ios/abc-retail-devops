<!DOCTYPE html>
<html>
<head>
    <title>ABC Technologies - Retail Portal</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 40px;
            background-color: #f4f4f4;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h2 {
            color: #333;
            text-align: center;
            margin-bottom: 30px;
        }
        h3 {
            color: #666;
            text-align: center;
            margin-bottom: 40px;
        }
        .button-container {
            text-align: center;
            margin-top: 30px;
        }
        .btn {
            display: inline-block;
            padding: 15px 30px;
            margin: 10px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-size: 16px;
            transition: background-color 0.3s;
        }
        .btn:hover {
            background-color: #45a049;
        }
        .btn-view {
            background-color: #008CBA;
        }
        .btn-view:hover {
            background-color: #007B9A;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Welcome to ABC Technologies</h2>
        <h3>Retail Management Portal</h3>
        
        <div class="button-container">
            <button name="Add Product" value="Add Product" type="button" onclick="addProduct()">Add Product</button>
            <button name="View Product" value="View Product" type="button" onclick="viewProduct()">View Product</button>
        </div>
    </div>

    <script>
    function addProduct() {
        alert("You will be navigated to Add module");
    }

    function viewProduct() {
        alert("You will be navigated to view module");
    }
    </script>
</body>
</html>

