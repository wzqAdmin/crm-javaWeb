<!--业务名称页面，即：发传单-->
<!--
  页面的作用：
   1：
    这个页面的作用是通过后台的activityController使用请求转发后，返回的数据
    在前端页面使用EL表达式展现后端转发过来的一个activity(市场活动的详细信息)

   2：
    对该页面上的备注信息进行操作，为什么要使用ajax请求的方式进行对备注信息的索取？
      因为这个页面上的备注信息也可以进行增删改查，例如：当我们删除一条备注信息时，备注信息必须刷新，而备注信息
      只占这个页面的一部分，所以不适合通过传统请求的方法进行获取备注信息
        这个刷新函数需要几个入口呢？
           1）当页面加载完毕后
           2）删除一条备注时
           3）添加一条备注时
           4）修改一条备注时
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

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});
		/*--------------------------------------------------------*/
		//在页面加载完毕后，展现该市场活动关联的备注信息列表
		showRemarkLsit();
		/*--------------------------------------------------------*/
        //当我们使用了showRemarkLsit函数会发现线索的修改和删除图标不见了，这时我们要使用bootstrap重新为其绑定事件，至于具体的实现原理，不需要我们去关心
        $("#remarkBody").on("mouseover",".remarkDiv",function(){
            $(this).children("div").children("div").show();
        })
        $("#remarkBody").on("mouseout",".remarkDiv",function(){
            $(this).children("div").children("div").hide();
        })
        /*-----------------------------------------------------*/
        //当用户输入完毕备注信息点击保存时
        $("#saveRemarkBtn").click(function () {

            //如果去除前后空白后，用户输入的备注信息为空，则表示这是一条无效的备注
            if($.trim($("#remark").val())==""){

                alert("备注信息不能为空");

            }else{
                //需要发送一个ajax请求，在后台的数据库中插入用户输入的备注
                $.ajax({
                    url:"workbench/activity/saveRemark.do",
                    data:{
                        /*
                         当用户需要添加备注参数时，前端需要给后端传递什么参数？
                            1、该市场活动的ID，作为备注表中的外键
                            2、用户填写的备注信息
                         */
                        "activityId":"${requestScope.a.id}",
                        "noteContent":$.trim($("#remark").val())  //去除用户填写的备注信息空白
                    },
                    dataType:"json",
                    type:"post",
                    success:function (data) {
                        /*
                           当插入备注信息后，我们需要后台返回什么？
                             {"success":true/false,"ar":{插入的备注信息}}
                         */
                        if (data.success){
                            //如果在后台数据库插入备注信息成功，则在前端需要拼接这个备注信息，拼接的位置在textarea文本域上方
                            var html="";

                            //textarea文本域中的信息清空掉
                            $("#remark").val("");

                            html+='<div class="remarkDiv" style="height: 60px;" id="'+data.ar.id+'">';
                            html+='<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
                            html+='<div style="position: relative; top: -40px; left: 40px;" >';
                            html+='<h5>'+data.ar.noteContent+'</h5>';
                            html+='<font color="gray">市场活动</font> <font color="gray">-</font> <b>${requestScope.a.name}</b> <small style="color: gray;"> '+(data.ar.createTime)+' 由'+(data.ar.createBy)+'</small>';
                            html+='<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
                            html+='<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';
                            html+='&nbsp;&nbsp;&nbsp;&nbsp;';
                            html+='<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;" onclick="deleteRemark(\''+data.ar.id+'\')"></span></a>';
                            html+='</div>';
                            html+='</div>';
                            html+='</div>';

                            //将备注信息插入到textarea文本域之前
                            $("#remarkDiv").before(html);




                        }else{
                            alert("插入备注信息失败");
                        }
                    }
                })
            }
        })
        /*----------------------------------------------------------------------------*/
        //当用户点击了备注修改确认按钮
        $("#updateRemarkBtn").click(function () {

            var id=$("#remarkId").val();  //从修改模态窗口的隐藏域中取出要修改备注的id

            //发出一个ajax请求，将用户要修改的备注内容传递给后台
            $.ajax({
                url:"workbench/activity/updateRemark.do",
                type:"post",
                data:{
                  "remarkId":id,
                  "noteContent":$.trim($("#noteContent").val()) //将修改模态窗口的修改文本域中的值取到
                },
                dataType:"json",
                success:function (data) {
                    /*
                       前端需要后端提供什么？
                         {"success":true/false,"ar":{备注信息}}
                        前端之所以还要备注信息的原因是：需要将页面中的备注信息铺成最新的
                     */
                    if(data.success){
                        /*
                          当后端的服务器修改成功后，要更新前端页面的数据,要更新的有
                            1、备注信息
                            2、修改人，修改时间
                         */
                        //更新页面的备注信息，我们如何确定这条备注信息呢？在前面的each循环中我们为每一条备注信息起了一个id： e+备注id
                         $("#e"+id).html(data.ar.noteContent);
                        //更新修改人和修改时间
                         $("#f"+id).html(data.ar.editTime+" 由"+data.ar.editBy);

                        //更新完毕后，关闭模态窗口
                        $("#editRemarkModal").modal("hide");

                    }else{

                      alert("修改备注信息失败");
                    }
                    
                }
            })
        })

    });
	//这个函数用于展现一条市场活动记录所关联的备注信息
	function showRemarkLsit(){
		//自动发出一个ajax请求
		$.ajax({
			url:"workbench/activity/showRemarkLsit.do",
			type:"get",
			data:{
				/*
				  这个业务需求是根据当前页面打开的市场活动的id，作为备注表外键，查询对应的备注信息，所以
				  往后端传递的参数是，市场活动的id，这个id在requestScope对象中存放着
				 */
				"activityId":"${requestScope.a.id}"
			},
			dataType:"json",
			success:function (data) {
				/*
				  前端需要后端返回的是什么？
                    由于一条市场活动可以有多条备注信息，所以，后端返回来的是备注信息的集合
                    {[{备注1},{备注2},....]}
				 */
				var html="";
				//循环后端返回的数据data，将每一条备注信息拼接到页面中
				$.each(data,function (i,n) {
				    html+='<div class="remarkDiv" style="height: 60px;" id="'+n.id+'">';
					html+='<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
					html+='<div style="position: relative; top: -40px; left: 40px;" >';
					html+='<h5 id="e'+n.id+'">'+n.noteContent+'</h5>';
					/*
					   这里的requestScope.a.name为什么不用写在字符串内呢？
					     因为在单引号内，本身就是字符串
					 */
					html+='<font color="gray">市场活动</font> <font color="gray">-</font> <b>${requestScope.a.name}</b> <small style="color: gray;" id="f'+n.id+'"> '+(n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
					html+='<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
					html+='<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;" onclick="editRemark(\''+n.id+'\')"></span></a>';
					html+='&nbsp;&nbsp;&nbsp;&nbsp;';
					/*
					   对于删除，我们为什么选择传统的绑定事件的方式，而不是为其指定一个id，通过id的click事件呢？
					     因为对于这个删除按钮，它在each循环中，为其指定id非常麻烦，而且也没有一个合适的id供我们去选择，至于超链接，就
					     更不可能了，因为你如果点击了它，他会立即跳转到该页面，无法在跳转之前执行其他的操作
					     
					   对于onclick事件的参数问题，在jQuery中，我们动态生成的标签绑定的事件参数必须套用在字符串中，字符串的使用规则如前所述
					   双引号里面包含单引号，单引号里面包含双引号，引号冲突问题可以通过转义字符解决
					 */
				    html+='<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;" onclick="deleteRemark(\''+n.id+'\')"></span></a>';
					html+='</div>';
					html+='</div>';
					html+='</div>';
				});
				//使用jQuery的before函数为idremarkDiv的前面拼接备注信息
				$("#remarkDiv").before(html);
			}
		})
	}
	function deleteRemark(id){
	   $.ajax({
           url:"workbench/activity/deleteRemark.do",
           type:"post",
           data:{
               "remarkId":id
           },
           dataType:"json",
           success:function (data) {
               /*
                 对于需要后端返回的信息
                  {"success":true/false} 删除成功或者失败
                */
               if(data.success){
                 //如果删除成功，则重新展现备注信息
                   /*
                     如果单纯的复用showRemarkLsit方法的话，由于这个方法使用的是id before会在那个id前面追加数据
                     会保留原有的数据，造成页面错误，为了避免这个问题，我们可以使用jQuery结合id，定位到要删除的id，
                     使用remove方法即可移除拼接的div
                    */
                   $("#"+id).remove();
               }else{

                 alert("删除备注信息失败");

               }
           }
       })
    }

    function editRemark(id){
	    //当用户点击修改按钮的时候，editRemark需要修改备注的id

        //将该备注的id存放到修改模态窗口的隐藏域中，目的是为了给后端传参，让后端知道修改哪个备注信息
        $("#remarkId").val(id);

        //取出原先的备注信息
        var noteContent = $("#e"+id).html();

        //将模态窗口的textarea文本域的值设置为原先的备注信息
        $("#noteContent").val(noteContent);

        //展现修改备注的模态窗口
        $("#editRemarkModal").modal("show");


    }
	
</script>

</head>
<body>
	
	<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
        <div class="modal-dialog" role="document" style="width: 40%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">修改备注</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" role="form">
                        <div class="form-group">
                            <label for="edit-describe" class="col-sm-2 control-label">内容</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="noteContent"></textarea>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
                </div>
            </div>
        </div>
    </div>

    <!-- 修改市场活动的模态窗口 -->
    <div class="modal fade" id="editActivityModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">修改市场活动</h4>
                </div>
                <div class="modal-body">

                    <form class="form-horizontal" role="form">

                        <div class="form-group">
                            <label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <select class="form-control" id="edit-marketActivityOwner">
                                    <option>zhangsan</option>
                                    <option>lisi</option>
                                    <option>wangwu</option>
                                </select>
                            </div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName" value="发传单">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-startTime" value="2020-10-10">
                            </div>
                            <label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-endTime" value="2020-10-20">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-cost" value="5,000">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-describe">市场活动Marketing，是指品牌主办或参与的展览会议与公关市场活动，包括自行主办的各类研讨会、客户交流会、演示会、新产品发布会、体验会、答谢会、年会和出席参加并布展或演讲的展览会、研讨会、行业交流会、颁奖典礼等</textarea>
                            </div>
                        </div>

                    </form>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" data-dismiss="modal">更新</button>
                </div>
            </div>
        </div>
    </div>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>市场活动-${requestScope.a.name}<small>${requestScope.a.startDate} ~ ${requestScope.a.endDate}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" data-toggle="modal" data-target="#editActivityModal"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.a.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${requestScope.a.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>

		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">开始日期</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${a.startDate}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${a.endDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">成本</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${a.cost}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${requestScope.a.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${requestScope.a.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${requestScope.a.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${requestScope.a.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
                    ${requestScope.a.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 30px; left: 40px;" id="remarkBody">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
		<!-- 备注1 -->
		<%--<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>--%>
		
		<!-- 备注2 -->
		<%--<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>--%>

        <!--添加备注的div-->
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="saveRemarkBtn">保存</button>
				</p>
			</form>
		</div>
	</div>
	<div style="height: 200px;"></div>
</body>
</html>