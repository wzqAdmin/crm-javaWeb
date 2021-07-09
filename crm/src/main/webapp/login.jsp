<!--
  登录页面
-->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
	<script>
		//当页面加载完成后执行
		$(function () {

			//如果这个登录页不是顶层窗口，那么就设置其为顶级窗口
			if(window.top!=window){
				window.top.location=window.location;
			}


			//在页面加载完毕后，将用户文本框中的内容清空，防止保存下一次缓存的结果
			/*
			   为什么不用html("")而用val("")?
			     因为操作的是text文本框的value属性，不是标签对中的内容<p>12313</p>
			 */
			$("#loginAct").val("");

			//让用户名输入文本框自动获得焦点
			/*
			   jQuery的focus函数的两种形式
			    $("选择器").focus();  为这个选择器选择的对象获得焦点
			    $("选择器").focus(function(){  当这个选择器选择的对象触发了获得焦点事件时，执行function函数
			     })
			 */
			$("#loginAct").focus();

			//当用户点击登录按钮时，执行登录操作
			$("#submitBtn").click(function () {
				login();
			})

			//当用户敲回车的时候，触发登录操作
			/*
			  event可以取得用户敲击哪个键的ascii码
			  回车键的ascii码为13
			 */
			$(window).keydown(function (event) {
				if(event.keyCode == 13){
					login();
				}
			})

		})

		/*
		   为什么要将login方法写在$(function())外面，因为$(function())内的函数
		   在页面加载完成后才被加载/执行，如果写在里面，入工会login方法内的css等样式过多
		   会导致一次加载的资源过多，响应慢
		*/
		function login(){
			//登陆限制：用户填写的账号或者密码不能为空
			  /*
			    当用户在账号或者密码栏中输入空格的使用也应该计算为空
			    使用jQuer的$.trim(字符串)去除字符串的前后空白
			   */
			var loginAct = $.trim($("#loginAct").val());
			var loginPwd = $.trim($("#loginPwd").val());

			if(loginAct == "" || loginPwd == ""){
				//这里使用html函数的原因是要对span标签对中添加数据，并不是value属性
				$("#msg").html("账号或密码不能为空");
				//如果账号或密码为空，则需要强制终止login()方法的执行，避免执行后面的ajax
				return false;
			}

			//当程序执行到这里，说明账号或密码没有为空，去后台数据库进行登录验证
			/*
			   必须要发送ajax请求的原因是什么?
			     因为用户返回的登录结果在页面的一小部分进行展示，如果发送传统请求，
			     整个页面都会重新加载，给用户得体验感觉不好
			 */
			$.ajax({
                //注意：在写web.xml文件的servlet资源路径的时候没有最前面的 ‘/’
                url:"settings/user/login.do",
                data:{
                       "loginAct" : loginAct,
                       "loginPwd" : loginPwd
                },
                //虽然是一个查询操作，但是传递的参数涉及到了密码，为了安全起见必须使用post请求方式
                type:"post",
                dataType:"json",
                success:function(data){
                    /*
                       前端需要后端返回什么(data)？
                         需要后端返回验证是否成功的结果，如果成功则返回true，否则返回false
                         { “success”:true/false，“msg“："出现的四种问题中的一种”}
                     */
                    //如果返回true，则代表后台验证通过
                    if(data.success){
                        window.location.href="workbench/index.jsp";

                    }else{
                        //通过后端返回的错误原因，提示用户哪个环节出了问题
                        $("#msg").html(data.msg);
                    }
                }
            })
		}
	</script>
</head>
<body>
	<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
		<img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
	</div>
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2017&nbsp;动力节点</span></div>
	</div>
	
	<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
		<div style="position: absolute; top: 0px; right: 60px;">
			<div class="page-header">
				<h1>登录</h1>
			</div>
			<form action="workbench/index.jsp" class="form-horizontal" role="form">
				<div class="form-group form-group-lg">
					<div style="width: 350px;">
						<input class="form-control" type="text" placeholder="用户名" id="loginAct">
					</div>
					<div style="width: 350px; position: relative;top: 20px;">
						<input class="form-control" type="password" placeholder="密码" id="loginPwd">
					</div>
					<div class="checkbox"  style="position: relative;top: 30px; left: 10px;">

						    <!--登录错误的提示消息 在前端显示的位置-->
							<span id="msg" style="color: red"></span>

					</div>
					<!--
					  当按钮写在form标签中，即使不指定按钮type类型，默认为submit
					  所以如果想让用户点击登录按钮转去进行判断登录业务，而不是直接提交到action
					  必须将type属性设置为button
					  按钮所触发的click事件应该是我们手动写js代码来实现的
					-->
					<button type="button" class="btn btn-primary btn-lg btn-block"  style="width: 350px; position: relative;top: 45px;" id="submitBtn">登录</button>
				</div>
			</form>
		</div>
	</div>
</body>
</html>