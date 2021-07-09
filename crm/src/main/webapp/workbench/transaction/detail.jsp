<%@ page import="com.bjpowernode.crm.settings.domain.DicValue" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.bjpowernode.crm.workbench.domain.Tran" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
  //准备字典typeCode类型为stage的字典值列表
  List<DicValue> dcList = (List<DicValue>) application.getAttribute("stageList");
  //准备可能性的列表，它存放在服务器缓存中
  Map<String,String> pMap = (Map<String, String>) application.getAttribute("pMap");
  //准备pMap中key的集合，即01需求分析,0....的部分
  Set<String> keySet =pMap.keySet();
  //取得正常阶段和丢失阶段分界点的下标,即可能性为0的点
  int point=0;
  for(int i=0;i<dcList.size();i++){
  	//相当于取出tbl_dic_value typeCode为stage集合中的一条记录
    DicValue dicValue =	dcList.get(i);
    String stage=dicValue.getValue();
    //取出这条记录的可能性，并判断可能性是否为0
	String possibility=pMap.get(stage);
	if("0".equals(possibility)){
		point=i;
		break;
	}
  }
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />

<style type="text/css">
.mystage{
	font-size: 20px;
	vertical-align: middle;
	cursor: pointer;
}
.closingDate{
	font-size : 15px;
	cursor: pointer;
	vertical-align: middle;
}
</style>
	
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
		
		
		//阶段提示框
		$(".mystage").popover({
            trigger:'manual',
            placement : 'bottom',
            html: 'true',
            animation: false
        }).on("mouseenter", function () {
                    var _this = this;
                    $(this).popover("show");
                    $(this).siblings(".popover").on("mouseleave", function () {
                        $(_this).popover('hide');
                    });
                }).on("mouseleave", function () {
                    var _this = this;
                    setTimeout(function () {
                        if (!$(".popover:hover").length) {
                            $(_this).popover("hide")
                        }
                    }, 100);
                });
		/*------------------------------------------------------------------------*/
		//当页面加载完成的时候，自动发出一个ajax请求展现交易信息列表
		showHistoryList();
	});

	function showHistoryList() {
		$.ajax({
			url:"workbench/transaction/getTranHistoryListByTranId.do",
			type:"get",
			data:{
			  "tranId":"${t.id}"
			},
			dataType:"json",
			success:function(data){
				/*
				   前端需要后端返回什么？
				    [{历史列表1},{历史列表2},{历史列表3}.....]
				 */
				var html="";
				$.each(data,function (i,n) {

				    html +='<tr>';
					html +='<td>'+n.stage+'</td>';
					html +='<td>'+n.money+'</td>';
					html +='<td>'+n.possibility+'</td>';
					html +='<td>'+n.expectedDate+'</td>';
					html +='<td>'+n.createTime+'</td>';
					html +='<td>'+n.createBy+'</td>';
					html +='</tr>';
				})
				$("#tranHistoryBody").html(html);
			}
		})
	}

	/*
	   stage:需要改变的阶段  01....，02....
	   i:需要改变的阶段下标
	 */
	function changeStage(stage,i) {
      //发出ajax请求，更新页面中的属性
		$.ajax({
			url:"workbench/transaction/changeStage.do",
			type:"post",
			data:{
			  "id":"${t.id}",
			  "stage":stage,
				//以下两条参数是为了后台能够生成交易历史，所必须的参数
			  "money":"${t.money}",
			  "expectedDate":$("#expectedDate").html()
			},
			dataType:"json",
			success:function (data) {
				/*
				   前端需要后端返回什么？
				    [{"success":true/false,"t":{交易对象}}]
				 */
				if (data.success){
					//如果成功，则需要局部更新页面中的内容
					//1)更新阶段、可能性、修改人、修改时间
					$("#stage").html(data.t.stage);
					$("#possibility").html(data.t.possibility);
					$("#editBy").html(data.t.editBy);
					$("#editTime").html(data.t.editTime);

					//改变页面的图标
					showStageImag(stage,i);

					//刷新历史列表
					showHistoryList();

				}else{
					alert("修改状态失败");
				}
			}
		})
	}
	
	function showStageImag(stage,index1) {
		//获取用户选择的阶段(当前阶段)
		var currentStage=stage;
		//获取当前阶段的下标
		var currentIndex=index1;
		//获取当前阶段的可能性
		/*
		   注意：这个可能性不能从request作用域对象中取值，因为我们点击了图标
		   调用的是ajax请求，页面局部刷新了，但是request作用域中的内容没有刷，还是维持原来的，所以我们要取
		   局部刷新后的数据
		 */
		var currentpossibility=	$("#possibility").html();
		//获取//前面正常阶段和后面丢失阶段的分界点下标
		var point="<%=point%>";
		//如果用户当前的阶段可能性为0 则代表前七个是黑圈，后两个一个红叉，一个黑叉
		if(currentpossibility=="0"){
			//遍历前七个
			for(i=0;i<point;i++){
				//黑圈--------------------
				//移除掉原有的样式
				$("#"+i).removeClass();
				//添加新样式
				$("#"+i).addClass("glyphicon glyphicon-record mystage");
				//为新样式赋予颜色
				$("#"+i).css("color","#000000");

			}
			//遍历后两个
			for (i=point;i<"<%=dcList.size()%>";i++){
				//如果是当前的阶段
				if (currentIndex==i){
					//红叉-------------------
					//1、清除原有样式
					$("#"+i).removeClass();
					//2、附加新样式
					$("#"+i).addClass("glyphicon glyphicon-remove mystage");
					//3、为新样式赋予颜色
					$("#"+i).css("color","#FF0000");
				} else{
					//黑叉-------------------------
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-remove mystage");
					$("#"+i).css("color","#000000");
				}
			}
		//如果当前用户的阶段可能性不为0，则代表前七个不一定，后两个肯定是黑叉
		}else{
			//遍历前七个
			for(i=0;i<point;i++){
				//如果是用户当前的阶段
				if(i==currentIndex){
					//绿色标记---------------
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-map-marker mystage");
					$("#"+i).css("color","#90F790");

				//如果小于当前阶段，则代表已经完成了该步
				}else if(i<currentIndex){
					//绿圈------------------
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-ok-circle mystage");
					$("#"+i).css("color","#90F790");

				//如果大于，则代表还没有到达该步
				}else{
					//黑圈------------------------
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-record mystage");
					$("#"+i).css("color","#000000");
				}
			}
			//遍历后两个
			for (i=point;i<"<%=dcList.size()%>";i++) {
			 //黑叉----------------------------------
				$("#"+i).removeClass();
				$("#"+i).addClass("glyphicon glyphicon-remove mystage");
				$("#"+i).css("color","#000000");
			}
		}
	}
	
</script>

</head>
<body>
	
	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${t.customerId}-${t.name} <small>￥${t.money}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" onclick="window.location.href='edit.html';"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>

	<!-- 阶段状态 -->
	<div style="position: relative; left: 40px; top: -50px;">
		阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<%
		  //准备当前阶段
		  Tran t= (Tran) request.getAttribute("t");
		  String currentStage = t.getStage();
		  //获取当前阶段的可能性
		  String possibility =pMap.get(currentStage);
		  //如果当前阶段的可能性为0 则代表，当前的阶段是后两个阶段，即08丢失的线索 和09，此时图标应该是红叉和黑叉，前七个为绿
		  if("0".equals(possibility)){
              //如何判断，当前阶段是08，还是09呢
			  /*
			     思路：需要遍历阶段的List集合，反复与当前的阶段进行比对，
			     如果比对成功，则可以确定当前阶段的位置
			   */
			  for(int i=0;i<dcList.size();i++){
			  	////取得每一个遍历出来的阶段，根据每一个遍历出来的阶段取其可能性
				DicValue dicValue = dcList.get(i);
				String liststage = dicValue.getValue();
				String listPossibility = pMap.get(liststage);
				//说明取到了后两个，需要知道当前的阶段处于这两个中的哪一个，来指定颜色
				if("0".equals(listPossibility)){
					//如果是当前阶段
					if(liststage.equals(currentStage)){
						//红色叉号------------------------------
		 %>
					<span id="<%=i%>" onclick="changeStage('<%=liststage%>','<%=i%>')"
						  class="glyphicon glyphicon-remove mystage"
						  data-toggle="popover" data-placement="bottom"
						  data-content="<%=dicValue.getText()%>" style="color: #FF0000;"></span>
					-----------
		 <%
					}else{
						//黑色叉号------------------------------
		  %>
				<span id="<%=i%>" onclick="changeStage('<%=liststage%>','<%=i%>')"
					  class="glyphicon glyphicon-remove mystage"
					  data-toggle="popover" data-placement="bottom"
					  data-content="<%=dicValue.getText()%>" style="color: #000000;"></span>
				-----------
		 <%
					}
				////如果遍历出来的阶段的可能性不为0，说明是前7个，一定是黑圈
				}else {
					//黑圈-----------------------------------------
		 %>

				<span id="<%=i%>" onclick="changeStage('<%=liststage%>','<%=i%>')"
					  class="glyphicon glyphicon-record mystage"
					  data-toggle="popover" data-placement="bottom"
					  data-content="<%=dicValue.getText()%>" style="color: #000000;"></span>
				-----------
		<%
				}
			  }
		  //如果当前阶段的可能性不为0，则代表 ，当前的阶段为前七个阶段，后两个阶段为黑叉，前七个需要再次判断
		  }else{

		  	 //准备当前阶段的下标
			  int index=0;
			  for(int i=0;i<dcList.size();i++){
			  	DicValue dicValue = dcList.get(i);
			  	String stage = dicValue.getValue();
			  	if(stage.equals(currentStage)){
			  		index=i;
			  		break;
				}
			  }
			  for(int i=0;i<dcList.size();i++){
				  DicValue dicValue = dcList.get(i);
				  String liststage = dicValue.getValue();
				  String listPossibility=pMap.get(liststage);
				  //如果遍历出来的阶段是0，则代表是黑叉，因为最外层的else已经决定了当前阶段的可能性不为0
				  if("0".equals(listPossibility)){
				  	//黑叉--------------------------
		%>

					<span id="<%=i%>" onclick="changeStage('<%=liststage%>','<%=i%>')"
						  class="glyphicon glyphicon-remove mystage"
						  data-toggle="popover" data-placement="bottom"
						  data-content="<%=dicValue.getText()%>" style="color: #000000;"></span>
					-----------

		<%
				  //如果不为0，说明是前七个阶段，则需要继续判断
				  }else {
				  	//如果i等于当前阶段的下标,代表是当前阶段
				  	if(i==index){
				  		//绿色标记----------------
		%>

					<span id="<%=i%>" onclick="changeStage('<%=liststage%>','<%=i%>')"
						  class="glyphicon glyphicon-map-marker mystage"
						  data-toggle="popover" data-placement="bottom"
						  data-content="<%=dicValue.getText()%>" style="color: #90F790;"></span>
					-----------

		<%
				    //如果小于当前阶段
					}else if(i<index){
				  		//绿圈
		%>
					<span id="<%=i%>" onclick="changeStage('<%=liststage%>','<%=i%>')"
						  class="glyphicon glyphicon-ok-circle mystage"
						  data-toggle="popover" data-placement="bottom"
						  data-content="<%=dicValue.getText()%>" style="color: #90F790;"></span>
					-----------

		<%
					//如果大于当前阶段
				  	}else{
				  	   //黑圈
		%>

					<span id="<%=i%>" onclick="changeStage('<%=liststage%>','<%=i%>')"
						  class="glyphicon glyphicon-record mystage"
						  data-toggle="popover" data-placement="bottom"
						  data-content="<%=dicValue.getText()%>" style="color: #000000;"></span>
					-----------

		<%
					}

				  }
			  }

		  }

		%>
		<%--<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="资质审查" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="需求分析" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="价值建议" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="确定决策者" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-map-marker mystage" data-toggle="popover" data-placement="bottom" data-content="提案/报价" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="谈判/复审"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="成交"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="丢失的线索"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="因竞争丢失关闭"></span>
		-----------
		<span class="closingDate">2010-10-10</span>--%>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: 0px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${t.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">金额</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${t.money}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${t.customerId}-${t.name}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">预计成交日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="expectedDate">${t.expectedDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">客户名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${t.customerId}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">阶段</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="stage">${t.stage}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">类型</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${t.type}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">可能性</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="possibility">${t.possibility}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">来源</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${t.source}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">市场活动源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${t.activityId}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">联系人名称</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${t.contactsId}</b></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${t.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">2017-01-18 10:10:10</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b id="editBy">${t.editBy}&nbsp;&nbsp;</b><small id="editTime" style="font-size: 10px; color: gray;">2017-01-19 10:10:10</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${t.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 90px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					&nbsp;${t.contactSummary}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 100px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${t.nextContactTime}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 100px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
		<!-- 备注1 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		
		<!-- 备注2 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 阶段历史 -->
	<div>
		<div style="position: relative; top: 100px; left: 40px;">
			<div class="page-header">
				<h4>阶段历史</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>阶段</td>
							<td>金额</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>创建时间</td>
							<td>创建人</td>
						</tr>
					</thead>
					<tbody id="tranHistoryBody">
						<%--<tr>
							<td>资质审查</td>
							<td>5,000</td>
							<td>10</td>
							<td>2017-02-07</td>
							<td>2016-10-10 10:10:10</td>
							<td>zhangsan</td>
						</tr>
						<tr>
							<td>需求分析</td>
							<td>5,000</td>
							<td>20</td>
							<td>2017-02-07</td>
							<td>2016-10-20 10:10:10</td>
							<td>zhangsan</td>
						</tr>
						<tr>
							<td>谈判/复审</td>
							<td>5,000</td>
							<td>90</td>
							<td>2017-02-07</td>
							<td>2017-02-09 10:10:10</td>
							<td>zhangsan</td>
						</tr>--%>
					</tbody>
				</table>
			</div>
			
		</div>
	</div>
	
	<div style="height: 200px;"></div>
	
</body>
</html>