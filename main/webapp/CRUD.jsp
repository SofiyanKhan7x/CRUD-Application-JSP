<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.* ,java.math.BigInteger" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CRUD Operations</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <style>
        body {
            background: #f8f9fa;
        }
        .container {
            margin-top: 30px;
        }
        h1 {
            color: #333;
        }
        table {
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="text-center mb-5">CRUD Application</h1>

        <!-- Backend Logic -->
        <%
            String url = "jdbc:postgresql://localhost:5432/Neon";
            String username = "postgres";
            String password = "suffu7x";
            Connection con = null;
            String action = request.getParameter("action");

            if (action != null) {
                try {
                    Class.forName("org.postgresql.Driver");
                    con = DriverManager.getConnection(url, username, password);

                    if (action.equals("create")) {
                    	int id = Integer.parseInt(request.getParameter("id"));
                        String firstname = request.getParameter("firstname");
                        String lastname = request.getParameter("lastname");
                        String phonenumber = request.getParameter("phonenumber");
                        long phoneNumberLong = Long.parseLong(phonenumber);

                        String insertQuery = "INSERT INTO suffu (id ,firstname, lastname, phonenumber) VALUES (?,?, ?, ?)";
                        PreparedStatement pst = con.prepareStatement(insertQuery);
                        pst.setInt(1,id);
                        pst.setString(2, firstname);
                        pst.setString(3, lastname);
                        pst.setLong(4, phoneNumberLong);
                        pst.executeUpdate();
                        out.println("<div class='alert alert-success'>Record Created Successfully!</div>");
                    } else if (action.equals("update")) {
                        int id = Integer.parseInt(request.getParameter("id"));
                        String firstname = request.getParameter("firstname");
                        String lastname = request.getParameter("lastname");
                        String phonenumber = request.getParameter("phonenumber");
                        long phoneNumberLong = Long.parseLong(phonenumber);
                  

                        String updateQuery = "UPDATE suffu SET firstname=?, lastname=?, phonenumber=? WHERE id=?";
                        PreparedStatement pst = con.prepareStatement(updateQuery);
                        pst.setString(1, firstname);
                        pst.setString(2, lastname);
                        pst.setLong(3, phoneNumberLong);
                        pst.setInt(4, id);
                    
                        
                        pst.executeUpdate();
                        out.println("<div class='alert alert-success'>Record Updated Successfully!</div>"); 
                        
                 
                    } else if (action.equals("delete")) {
                        int id = Integer.parseInt(request.getParameter("id"));
						
                        //Move to Recycle Bin
                        String MoveToRecycleBinQuery = "INSERT INTO recyclebin SELECT * FROM suffu WHERE id=?";
                        PreparedStatement pst = con.prepareStatement(MoveToRecycleBinQuery);
                        pst.setInt(1, id);
                        pst.executeUpdate();
                        
                        
                        //  Temporory Delete from the main
                        
                        String deleteQuery = "DELETE FROM suffu WHERE id=?";
                        PreparedStatement Dpst = con.prepareStatement(deleteQuery);
                        Dpst.setInt(1,id);
                        Dpst.executeUpdate();
                        
                        out.println("<div class='alert alert-warning'>Data Move to Recycle bin Successfully!</div>");
                    } else if(action.equals("restore")){
                    	int id = Integer.parseInt(request.getParameter("id"));
                    	
                    	//Move to main
                    	String MoveToMain = "INSERT INTO suffu SELECT * FROM recyclebin WHERE id=?";
                    	PreparedStatement Mpst = con.prepareStatement(MoveToMain);
                    	Mpst.setInt(1,id);
                    	Mpst.executeUpdate();
                    	
                    	// Delete From the Recycle Bin
                    	
                    	String deleteQuery = "DELETE FROM recyclebin WHERE id=? ";
                    	PreparedStatement Dpst = con.prepareStatement(deleteQuery);
                    	Dpst.setInt(1,id);
                    	Dpst.executeUpdate();
                    	out.println("<div class='alert alert-success'>Data Restored Successfully!</div>");
                    } else if(action.equals("permanentDelete")){
                    	
                    	int id = Integer.parseInt(request.getParameter("id"));
                    	
                    	String deleteQuery = "DELETE FROM recyclebin WHERE id=?";
                    	PreparedStatement Dpst = con.prepareStatement(deleteQuery);
                    	Dpst.setInt(1,id);
                    	Dpst.executeUpdate();
                    	out.println("<div class='alert alert-danger'>Data Deleted Successfully!</div>");
                    	
                    }
                } catch (Exception e) {
                    out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                } 
               /* finally {
                    if (con != null) {
                        try {
                            con.close();
                        } catch (Exception e) {
                            out.println("<div class='alert alert-danger'>Error Closing Connection: " + e.getMessage() + "</div>");
                        }
                    }
                } */
            }
        %>

        <!-- Create Operation -->
        <form method="post">
            <div class="row g-3">
              <div class="col-md-3">
                    <input type="number" name="id" class="form-control" placeholder="Id" required>
                </div>
                <div class="col-md-3">
                    <input type="text" name="firstname" class="form-control" placeholder="First Name" required>
                </div>
                <div class="col-md-3">
                    <input type="text" name="lastname" class="form-control" placeholder="Last Name" required>
                </div>
                <div class="col-md-3">
                    <input type="text" name="phonenumber" class="form-control" placeholder="Phone Number" required>
                </div>
                <div class="col-md-3">
                    <button type="submit" name="action" value="create" class="btn btn-primary fs-5 fw-bold" style="width:1300px;">Create</button>
                </div>
            </div>
        </form>

        <hr>

        <!-- Read Operation -->
        <h3>Records in the Database</h3>
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>First Name</th>
                    <th>Last Name</th>
                    <th>Phone Number</th>
                    <th>Actions</th>
                   
                </tr>
            </thead>
            <tbody>
                <%
                    try {
                        Class.forName("org.postgresql.Driver");
                        con = DriverManager.getConnection(url, username, password);

                        String readQuery = "SELECT * FROM suffu";
                        Statement stmt = con.createStatement();
                        ResultSet rs = stmt.executeQuery(readQuery);

                        while (rs.next()) {
                            int id = rs.getInt("id");
                            String firstname = rs.getString("firstname");
                            String lastname = rs.getString("lastname");
                            String phonenumber = rs.getString("phonenumber");
                %>
                <tr>
                    <td><%= id %></td>
                    <td><%= firstname %></td>
                    <td><%= lastname %></td>
                    <td><%= phonenumber %></td>
                    <td>
                        <!-- Update Form -->
                        <form method="post" class="d-inline">
                            <input type="hidden" name="id" value="<%= id %>">
                            <input type="text" name="firstname" value="<%= firstname %>" class="form-control mb-2" placeholder="Edit First Name">
                            <input type="text" name="lastname" value="<%= lastname %>" class="form-control mb-2" placeholder="Edit Last Name">
                            <input type="text" name="phonenumber" value="<%= phonenumber %>" class="form-control mb-2" placeholder="Edit Phone Number">
                            <button type="submit" name="action" value="update" class="btn btn-warning btn-sm">Update</button>
                        </form>

                        <!-- Delete Form -->
                        <form method="post" class="d-inline">
                            <input type="hidden" name="id" value="<%= id %>">
                            <button type="submit" name="action" value="delete" class="btn btn-danger btn-sm">Delete</button>
                        </form>
                    </td>
                </tr>
                <%
                        }
                        rs.close();
                        stmt.close();
                    } catch (Exception e) {
                        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
                    } 
               /* finally {
                        if (con != null) {
                            try { con.close(); } catch (Exception e) {}
                        }
                    } */
                %>
            </tbody>
        </table>
        
        <!-- Read from Recycle Bin Table -->
        
        <h3>Records From Recycle Bin</h3>
        <table class="table table-bordered table-striped">
        	<thead>
        		<tr>
        			<th>Id</th>
        			<th>First Name</th>
        			<th>Last Name</th>
        			<th>Phone Number</th>
        			<th>Actions</th>
        		
        		</tr>
        	</thead>
        	<tbody>
        		<%
        			try{
        				String readQuery = "SELECT * FROM recyclebin";
        				Statement st = con.createStatement();
        				ResultSet rs = st.executeQuery(readQuery);
        				
        				while(rs.next()){
        					int id = rs.getInt("id");
        					String firstname = rs.getString("firstname");
        					String lastname = rs.getString("lastname");
        					long phonenumber = rs.getLong("phonenumber");
        					
        					
        					
        					
        		%>
        		<tr>
        			<td><%= id %></td>
        			<td><%= firstname %></td>
        			<td><%= lastname %></td>
        			<td><%= phonenumber %></td>
        			<td>
                        <form method="post" style="display:inline;">
                            <input type="hidden" name="id" value="<%= id %>">
                            <button type="submit" name="action" value="restore" class="btn btn-success btn-sm">Restore</button>
                        </form>
                        <form method="post" style="display:inline;">
                            <input type="hidden" name="id" value="<%= id %>">
                            <button type="submit" name="action" value="permanentDelete" class="btn btn-danger btn-sm">Permanently Delete</button>
                        </form>
                    </td>
        		
        		
        		</tr>
        		
        		<%			
        			}
        				
        			}catch(Exception e){
        				  out.println("<tr><td colspan='5'>Error: " + e.getMessage() + "</td></tr>");
                    
        			}finally {
                if (con != null) {
                    try { con.close(); } catch (Exception e) {}
                }
            } 
        		
        		%>
        	
        	</tbody>
        
        </table>
    </div>
</body>
</html>