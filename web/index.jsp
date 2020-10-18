<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head>
    <title>JSDOM</title>
    <script type="text/javascript">
      var count = 0;
      var cells = [];
      var new_XMLDOM = null;
      var xmlHttp;

      function addRow(tableId, cells) {
        var tableElem = document.getElementById(tableId);
        var newRow = tableElem.insertRow(tableElem.rows.length);
        var newCell;
        for (var i = 0; i < cells.length; i++) {
          newCell = newRow.insertCell(newRow.cells.length);
          newCell.innerHTML = cells[i];
        }
        return newRow;
      }

      function deleteRow(tableId, rowNumber) {
        var tableElem = document.getElementById(tableId);
        if (rowNumber > 0 && rowNumber < tableElem.rows.length) {
          tableElem.deleteRow(rowNumber);
        } else {
          alert("Failed");
        }
      }

      function getXmlHttpObject() {
        var xmlHttp = null;
        try { //tích hợp trong 1 số trình duyệt: Firefox/Opera 8+/Safari
          xmlHttp = new XMLHttpRequest();
        } catch (e) { //catch dùng cho IE
          try {
            xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
          } catch (e) {
            xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
          }
        }
        return xmlHttp;
      }

      function searchNode(node, strSearch, tableName) {
        if (node == null) {
          return;
        }
        if (node.tagName == "booktitle") {
          var tmp = node.firstChild.nodeValue;
          if (tmp.indexOf(strSearch, 0) > -1) {
            var parent = node.parentNode;
            var attrId = parent.attributes.getNamedItem("id").text;
            new_XMLDOM += "<book id='" + attrId + "'>";
            count++;
            cells[0] = count;
            cells[1] = attrId;
            cells[2] = node.firstChild.nodeValue;
            new_XMLDOM += "<booktitle>" + node.firstChild.nodeValue + "</booktitle>";
            var author = node.nextSibling;
            cells[3] = author.firstChild.nodeValue;
            new_XMLDOM += "<author>" + author.firstChild.nodeValue + "</author>";
            var price = author.nextSibling;
            cells[4] = price.firstChild.nodeValue;
            new_XMLDOM += "<price>" + price.firstChild.nodeValue + "</price>";
            addRow(tableName, cells);
            new_XMLDOM += "</book>";
          }
        }

        var childs = node.childNodes;
        for (var i = 0; i < childs.length; i++) {
          searchNode(childs[i], strSearch, tableName);
        }
      }

      function traversalDOMTree(fileName, tableName) {
        var tableElem = document.getElementById(tableName);
        var i = 1;
        while (i < tableElem.rows.length) {
          deleteRow(tableName, i);
        }
        count = 0;
        new_XMLDOM = null;
        var xmlDOM = new ActiveXObject("Microsoft.XMLDOM");
        new_XMLDOM = '<library xmlns="http://hieulh.com/library">';
        xmlDOM.async = false;
        xmlDOM.load(fileName);
        if (xmlDOM.parseError.errorCode != 0) {
          alert("Error: " + xmlDOM.parseError.reason);
        } else {
          searchNode(xmlDOM, myForm.txtSearch.value, tableName);
          new_XMLDOM += "</library>";
          alert(new_XMLDOM);
        }
      }

      function update() {
        xmlHttp = getXmlHttpObject();
        if (xmlHttp == null) {
          alert("Your browser does not support AJAX");
          return;
        }
        xmlHttp.open("POST", "Controller", true);
        xmlHttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        var url = "btAction=update&xmlContent=";
        url += new_XMLDOM;
        xmlHttp.send(url);
      }
    </script>
  </head>
  <body>
    <h1>JavaScript with DOM Demo</h1>
    <form name="myForm">
      Name: <input type="text" name="txtSearch" value=""/> <br/>
      <input type="button" value="Search" onclick="traversalDOMTree('./library.xml', 'dataTable')"/>
    </form>
     <!-- <table border="1" id="dataTable">
      <thead>
        <tr>
          <th>No</th>
          <th>Code</th>
          <th>Title</th>
          <th>Author</th>
          <th>Price</th>
        </tr>
      </thead>
    </table> -->
    <form name="updateForm">
      <input type="button" value="Synchronize" onclick="update()"/>
    </form>
  </body>
</html>
