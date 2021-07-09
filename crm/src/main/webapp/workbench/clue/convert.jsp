<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>


<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

<script type="text/javascript">
	$(function(){

		//加入日期控件
		$(".time").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "top-left"
		});
		$("#isCreateTransaction").click(function(){
			if(this.checked){
				$("#create-transaction2").show(200);
			}else{
				$("#create-transaction2").hide(200);
			}
		});

		/*------------------------------------------------*/
		//当用户点击市场活动源表单的时候，打开添加市场活动的模态窗口
		$("#openSearchModalBtn").on("click",function () {
			//打开绑定市场活动的模态窗口
			$("#searchActivityModal").modal("show");
		})

		/*为用户添加交易所查询的市场活动绑定键盘事件*/
		$("#searchActivityText").on("keydown",function (event) {

			if(event.keyCode==13){
				/*
				   发送一个ajax请求，查询出所有的市场活动信息
				 */
				$.ajax({
                   url:"workbench/clue/getActivityListByActivityName.do",
					data:{
                      "aname":$.trim($("#searchActivityText").val())
					},
					dataType:"json",
					type:"get",
					success:function (data) {
						/*
						   前端需要后端返回什么？
						    [{市场活动1},{2},{3}....]
						 */
						var html="";

						$.each(data,function (i,n) {

							html+='<tr>';
							/*
							   以后我们要点击这个单选按钮绑定市场活动，所以需要这个市场活动的id
							   作为这个单选按钮的value属性
							 */
							html+='<td><input type="radio" value="'+n.id+'" name="xz"/></td> ';
							html+='<td id="'+n.id+'">'+n.name+'</td>';
							html+='<td>'+n.startDate+'</td>';
							html+='<td>'+n.endDate+'</td>';
							html+='<td>'+n.owner+'</td>';
							html+='</tr>';
						})
						$("#activitySearchBody").html(html);
					}
				})

				return false;  //与前面一样，这个事件会将页面刷新，所以不能让这个方法正常执行完毕
			}
		})
		/*----------------------------------------------------------------------------------*/
		//当用户点击了市场活动源的提交按钮
		$("#subBtn").click(function () {

			//将市场活动的名称添加到市场活动源的表单上
			var $xz = $("input[name=xz]:checked");
			var aId = $xz.val();
			//将市场活动的名称添加到市场活动源文本框中 将这个市场活动的id添加到隐藏域中(方便开发)
			var aName=$("#"+aId).html();
			$("#activityName").val(aName);
			$("#activityId").val(aId);

			//关闭模态窗口
			$("#searchActivityModal").modal("hide");

		})
		/*------------------------------------------------------------------------------------*/
		//当用户点击了线索转换按钮
		/*
		  分为两种情况：
		    1、要在转换的同时添加交易
		    2、仅仅只是转换线索
		  不论是哪种情况，当用户点击了转换线索以后，当前页面刷新，并且线索列表少一条记录
		  当用户点击转换之后，转换的页面需要全部刷新，不需要局部刷新，所以我们需要发送传统请求的方式
		 */
        $("#convertBtn").click(function () {
          //判断用户是否选择了添加交易

			if($("#isCreateTransaction").prop("checked")){
				/*
				  当我们转换线索的同时要创建交易，必须将用户填写的那些表单页提交
				  包含：金额，预计成交日期，交易名称，阶段，市场活动源（id），在jQuery中为我们提供了提交表单的方法
				  submit();
				*/
				$("#tranFrom").submit();

			}else {
				/*
				  当我们不需要添加交易的时候，只需要告诉后台
				  我们需要转换哪条线索即可，所以要传递线索的id，反之，由于线索的id在detail.jsp中以传统请求的方式传递过来
				  而JSP的本质就是Servlet，可以使用隐式对象param来获取这个参数
				 */
				window.location.href="workbench/clue/convert.do?clueId=${param.id}";
			}
		})
	});
</script>

</head>
<body>
	
	<!-- 搜索市场活动的模态窗口 -->
	<div class="modal fade" id="searchActivityModal" role="dialog" >
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">搜索市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" id="searchActivityText" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="activitySearchBody">
							<%--<tr>
								<td><input type="radio" name="activity"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>
							<tr>
								<td><input type="radio" name="activity"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>--%>
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button"  id="subBtn" class="btn btn-primary" >提交</button>
				</div>
			</div>
		</div>
	</div>

	<div id="title" class="page-header" style="position: relative; left: 20px;">
		<!---
		   在el表达式中，除了作用域对象requestScope、application、sessionScope、pageScope以外
		  为了完善el表达式中的内容，el表达式还提供了一些隐式对象
		   其中的param的作用是获取请求参数的值 相当于 request.getParameter
		---->
		<h4>转换线索 <small>${param.fullname}${param.appellation}-${param.company}</small></h4>
	</div>
	<div id="create-customer" style="position: relative; left: 40px; height: 35px;">
		新建客户：${param.company}
	</div>
	<div id="create-contact" style="position: relative; left: 40px; height: 35px;">
		新建联系人：${param.fullname}${param.appellation}
	</div>
	<div id="create-transaction1" style="position: relative; left: 40px; height: 35px; top: 25px;">
		<input type="checkbox" id="isCreateTransaction"/>
		为客户创建交易
	</div>
	<div id="create-transaction2" style="position: relative; left: 40px; top: 20px; width: 80%; background-color: #F7F7F7; display: none;" >
	
		<form id="tranFrom" action="workbench/clue/convert.do" method="post">
			<!--
			  以隐藏域的形式提交clueId
			-->
			<input type="hidden" name="clueId" value="${param.id}">
			<!--
			  这个flag用于让后台判断是否要同时添加交易
			-->
			<input type="hidden" name="flag" value="a">
		  <div class="form-group" style="width: 400px; position: relative; left: 20px;">
		    <label for="amountOfMoney">金额</label>
		    <input type="text" class="form-control" id="amountOfMoney" name="money">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="tradeName">交易名称</label>
		    <input type="text" class="form-control" id="tradeName" name="name">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="expectedClosingDate">预计成交日期</label>
		    <input type="text" class="form-control time" id="expectedClosingDate" name="expectedDate">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="stage">阶段</label>
		    <select id="stage"  class="form-control" name="stage">
		    	<option></option>
				<!--
				   在数据字典中取出选项的信息
				-->
		    	<c:forEach items="${stageList}" var="s">
					<option value="${s.value}">${s.text}</option>
				</c:forEach>
		    </select>
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="activity">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" id="openSearchModalBtn"  style="text-decoration: none;"><span class="glyphicon glyphicon-search"></span></a></label>
		    <input type="text" id="activityName" class="form-control" id="activity" placeholder="点击上面搜索" readonly>
			 <!--
			    这个id是存放市场活动的id，目的是当我们要同时创建交易的时候，交易表中存放的是
			    市场活动的id，并非市场活动的名字，但这个id没必要给用户展示，所以要以隐藏域的形式保存在页面中
			 -->
			  <input type="hidden" id="activityId" name="activityId"/>
		  </div>
		</form>
		
	</div>
	
	<div id="owner" style="position: relative; left: 40px; height: 35px; top: 50px;">
		记录的所有者：<br>
		<b>${param.owner}</b>
	</div>
	<div id="operation" style="position: relative; left: 40px; height: 35px; top: 100px;">
		<input class="btn btn-primary" id="convertBtn" type="button" value="转换">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input class="btn btn-default" type="button" value="取消">
	</div>
</body>
</html>