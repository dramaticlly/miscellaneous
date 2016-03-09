import java.sql.*;
import java.io.*;

/*
javac Uber.java
java -cp /local/packages/jdbc-postgresql/postgresql-8.4-701.jdbc4.jar: Uber
*/
class Uber {

    public static void main(String args[]) throws IOException {
        String url;
        Connection conn;
        PreparedStatement pStatement;
        ResultSet rs;
        String queryString;
        int client_id = 0;

        try {
            Class.forName("org.postgresql.Driver");
        }
        catch (ClassNotFoundException e) {
            System.out.println("Failed to find the JDBC driver");
        }

        try {
            // In this try block, you should
            // 1) Connect to the database and set the search path
            url = "jdbc:postgresql://localhost:5432/csc343h-c6zhangj";
            conn = DriverManager.getConnection(url, "c6zhangj", "");

            /* pset the search path*/
            queryString = "SET search_path TO uber;";                                             
            pStatement = conn.prepareStatement(queryString);                                                  
            pStatement.execute();   

            // 2) Prompt the user for the name of a client
            BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
            System.out.println("Look up which client? [firstname surname]");
            String who = br.readLine();
            String[] name = who.split("\\s+");

            //System.out.println(" client: "+name[0]+" "+name[1]);
            
            // 3) Make the appropriate database query string
            //    (use the '?' placeholder!!)
            queryString = "select client_id from Client where firstname = ? and surname = ?";
            PreparedStatement ps = conn.prepareStatement(queryString);
            ps.setString(1,name[0]);
            ps.setString(2,name[1]);
            rs = ps.executeQuery();

            while (rs.next()) {                                             
                client_id = rs.getInt("client_id");                             
                //System.out.println("client_id: "+client_id);      
            } 

            // find request given client_id
            //System.out.println("find request given clien");
            int [] request_id = new int[64];
            int i = 0;
            queryString = "select request_id from Request where client_id = ?";
            ps = conn.prepareStatement(queryString);
            ps.setInt(1, client_id);
            rs = ps.executeQuery();
            while (rs.next()) {                                             
                request_id[i] = rs.getInt("request_id");                             
                //System.out.println("request_id: ["+i+"] :"+request_id[i]);   
                i ++;   
                if (i > 63) break;
            } 

            // 4) Output the results
            // find all driver based on request id
            //System.out.println("find driver name");
            int j ;
            for (j = 0; j < i; j++){
                queryString = "select firstname||' '||surname as dname from Dispatch JOIN Driver on Dispatch.driver_id = Driver.driver_id where request_id = ?";
                ps = conn.prepareStatement(queryString);
                ps.setInt(1, request_id[j]);
                rs = ps.executeQuery();
                // output for request[j]
                while(rs.next()){
                    String dname = rs.getString("dname");
                    System.out.println("driver: "+dname);
                }
            }

            // 5) Close the connection
        }
        catch (SQLException se) {
            System.err.println("SQL Exception." +
                    "<Message>: " + se.getMessage());
        }
    }
}


//select client_id from Client where firstname='Daisy' and surname='Mason';
// 99
//select request_id from Request where client_id = 99;
//1
/*
select firstname||' '||surname as dname from Dispatch JOIN Driver on Dispatch.
driver_id = Driver.driver_id where request_id = 1;
  dname   
----------
 Jon Snow
(1 row)
*/
