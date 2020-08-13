<%-- Masthan Swamy --%>

<%@ page import="java.sql.*" %>

<%
    // setting the default user as 1, since there is no login page
    session.setAttribute("userid",1);
    int defaultUserId = (Integer) session.getAttribute("userid");

    // registering the driver class
    Class.forName("com.mysql.jdbc.Driver");
    // establishing the connection
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/simplebanking","scott","Masthan555!");

    Statement st = con.createStatement();
    PreparedStatement pst;
    ResultSet rs;
%>

<%
    // This if statement, is used to handle Fund Transfer Request in POST Method.
    if(request.getMethod().equals("POST"))
    {
        // getting the from and to details from session and request.
        int from = (Integer) session.getAttribute("userid");
        int to = Integer.valueOf(request.getParameter("to"));

        // checking whether the Recipient Exists in the User Database.
        pst = con.prepareStatement("select * from users where accountno=?");
        pst.setInt(1,to);

        rs = pst.executeQuery();

        // if user exists, then continue the transaction
        if(rs.next())
        {
            // checking whether the sender has enough amount in his Account, and reducing his Account Balance
            int res1 = st.executeUpdate("update users set amount=amount-1000 where accountno="+from+" and amount>=1000");

            // if the above statement executed, continue with the Remaining Transaction.
            if(res1==1)
            {
                // setting the Default Amount of 1000 rs as stated in mail.
                int amount = 1000;

                // Increasing the Account Balance of Receiver
                st.executeUpdate("update  users set amount=amount+1000 where accountno="+to);

                // Inserting the transaction into the database
                st.executeUpdate("insert into transactions(amount_from,amount_to,amount) values("+from+","+to+","+amount+")");
            }
            else
            {
                // if user don't have enough balance, alerting the Sender
                out.print("<script> alert('You dont have Enough Balance in your Account.'); </script>");
            }
        }
        else
        {
            // If the Receiver Account Doesn't Exist in the Database, Alerting the Sender
            out.print("<script> alert('Sorry Account No Doesn't Exist.'); </script>");
        }
    }
%>

<html>
<head>

    <style>
        .mainName
        {
            text-align: center;
            padding-top: 25px;
            color: chocolate;
            font-size: 40px;
            text-decoration: underline;
            font-family: Bahnschrift;
        }
        .sideName
        {
            text-align: center;
            margin-top: 20px;
            text-decoration: underline;
        }
        table
        {
            margin-left: 15%;
        }
        td
        {
            text-align: center;
        }
        #transfer
        {
            width: 15%;
            cursor: pointer;
            padding : 10px;
            color : white;
            font-weight: bold;
            background-color: chocolate;
            margin-left: 15%;
        }
        .box1
        {
            border: 1px solid #cccccc;
            border-radius: 10px;

            margin: 20px 20% 25px 20%;
            padding: 10px;
        }
    </style>

</head>
<body>

<p class="mainName">My Account</p>

<div class="box1">

    <%
        // Querying the User Details.
        rs = st.executeQuery("select * from users where accountno="+defaultUserId);
        while(rs.next())
        {
    %>
        <%-- setting user details --%>
        <h2 style="margin-left: 15%;color: #3c3131;display: inline-block;">Name : <span style="color: chocolate"><% out.print(rs.getString("name")); %></span>,</h2>
        <h2 style="margin-left: 30%;color: #3c3131;display: inline-block;">Account Balance : <span style="color: chocolate"><% out.print(rs.getInt("amount")); %></span></h2>
    <%
        }
    %>
    <br>


    <h2 class="sideName">Your Last Transactions</h2>
    <table border="1" width="75%">
        <tr>
            <td>Amount</td>
            <td>From</td>
            <td>To</td>
            <td>Date</td>
        </tr>
    <%
        // Querying the Previous Transactions.
        rs = st.executeQuery("select * from transactions where amount_from="+defaultUserId+" or amount_to="+defaultUserId+" order by transaction_date desc limit 5");
        // This stat is used, Whether the Transactions available or not
        boolean stat = false;
            while(rs.next())
            {
        %>

        <%-- Setting the Transaction Details. --%>
                <tr>
                    <td><% out.print(rs.getInt("amount")); %></td>
                    <td><% out.print(rs.getInt("amount_from")); %></td>
                    <td><% out.print(rs.getInt("amount_to")); %></td>
                    <td><% out.print(rs.getTimestamp("transaction_date")); %></td>
                </tr>
        <%
                // if transactions exist, This Stat Becomes true
                stat = true;
            }
        %>

        <%
            // if stat is false, Then there are no Transactions
            if(!stat)
            {
        %>
                <tr>
                    <td colspan="4"><p>You Do not have any Previous Transactions</p></td>
                </tr>
        <%
            }
        %>

    </table>

    <button id="transfer" style="margin-top: 25px">Fund Transfer</button>

</div>

    <%-- This Form is used to send the Receiver Account no, to the Server in POST Method, Using Hidden Form Field --%>
    <%-- Data is sent this JSP Page only, And We Already had Written Code to handle this Request --%>
    <form action="AccountPage.jsp" method="post" id="transferForm">
        <%-- This Hidden Form Field, Contains the Receiver's Account No --%>
        <input type="hidden" name="to"id="to" />
    </form>

</body>

<script>
    // when the Fund Transfer Button is Clicked.
    document.getElementById("transfer").onclick = function(){

        // get receiver Account No. Using "Prompt Alert".
        let data = prompt("Enter Account No of Person : ");
        if(data!=null && data!=="")
        {
            // set the data in Hidden Form Field.
            document.getElementById("to").setAttribute("value",data);
            // and Submit the Form.
            document.getElementById("transferForm").submit();
        }
    }
</script>


</html>