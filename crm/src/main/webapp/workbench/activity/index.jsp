<!--市场活动主页面-->
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
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

	<!--
	   引入bootstarp的分页插件
	     注意：必须要在引入jQuery和bootstrap之后引入，因为只有有了前两项，才能有后面的分页插件
	     换句话说，分页插件是依赖于jQuery和bootstrap的
	-->
<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>


<script type="text/javascript">

	$(function(){
	/*----------------------------------------------------------------------------------*/

		//在创建模态窗口的 开始日期 和 结束日期栏 上加入事件控件
		//这里的time类时bootstrap写好的
		$(".time").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "bottom-left"
		});
   /*--------------------------------------------------------------------------------*/

		//当addBtn被单击时，执行function函数，打开模态窗口（创建市场活动）
		$("#addBtn").click(function () {

			/*
			  在显示模态窗口之间应该走一下后台，把市场活动的所有者从数据库表中查询出来，
			  填充到模态窗口的的select标签内，让用户选择为哪个用户创建模态窗口，可选的值为t_user表中所有的姓名
			  发送的请求是ajax请求
			    这个ajax请求返回的参数是，tbl_user表中所有的数据
			 */
			$.ajax({
				url:"workbench/activity/getUserList.do",
				/*data:{}, 因为不需要为后端传递参数，所以不用写data*/
				type:"get",
				dataType:"json",
				success:function (data) {

					var opt="";

                  //执行成功后遍历这个返回的User类型的json数组，来填充select下拉列表
					//[{id:?,name:?....}]
					$.each(data,function (i,n) {
						//i: 循环的索引(下标)  n：数组中的成员arr[i]
						opt+="<option value='"+n.id+"'>"+n.name+"</option>";
					});

					//将拼接的下拉列表填充到select标签内
					$("#create-owner").html(opt);

					//让所有者的名字那里默认选择当前登录的人名
					/*
					  注意：我们以前的EL表达式一般写在html代码中，
					       但是，jQuery中也可以写el表达式，要注意的是：要用“”括起来，否则报错
					 */
					var id="${sessionScope.user.id}";
					$("#create-owner").val(id);

					//显示模态窗口
					/*
                       操作模态窗口的方法
                         1、获取操作模态窗口的jQuery对象，调用modal方法 有两个参数：
                             show 打开模态窗口
                             hide 隐藏模态窗口
                     */
					$("#createActivityModal").modal("show");
				}
			})
		})

       /*-----------------------------------------------------------------------*/
		//当用户在创建市场活动的时候点击保存的时候，我们要往后端发送数据
		$("#saveBtn").click(function () {

			//发送ajax请求，将用户填写的数据发送给后端的controller
			$.ajax({
				url:"workbench/activity/add.do",
				data:{
					/*
                      为了防止用户输入的时候带空格，所以要去除前后的空格
                      使用jQuery的$.trim(参数)方法
                     */
					"owner" : $.trim($("#create-owner").val()),
					"name" : $.trim($("#create-name").val()),
					"startDate" : $.trim($("#create-startDate").val()),
					"endDate" : $.trim($("#create-endDate").val()),
					"cost" : $.trim($("#create-cost").val()),
					"description" : $.trim($("#create-description").val())
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					/*
                       前端需要得到的是在数据库中插入是否成功的标志
                        {"success",true/false}
                     */
					if(data.success){

						//当用户添加成功后
						//1、局部刷新页面的显示
						pageList(1,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
						//2、关闭创建市场活动模态窗口
						$("#createActivityModal").modal("hide");

						//3、清空上一次模态窗口中的数据
						/*
                         注意：
                            我们拿到了form表单的jquery对象
                            对于表单的jquery对象，提供了submit()方法让我们提交表单
                              $("#activityAddForm").submit();
                            但是表单的jquery对象，没有为我们提供reset()方法让我们重置表单（坑：idea为我们提示了有reset()方法）

                            虽然jquery对象没有为我们提供reset方法，但是原生js为我们提供了reset方法
                            所以我们要将jquery对象转换为原生dom对象

                            jquery对象转换为dom对象：
                                jquery对象[下标]

                            dom对象转换为jquery对象：
                                $(dom)
                         */
						$("#activityAddForm")[0].reset();

					}else{
						alert("保存失败！");
					}
				}

			})
		})

		/*--------------------------------------------------------------------------------*/
		//在页面加载完毕后，触发pageList方法，页面加载完毕的时机就是用户点击左侧菜单中的"市场活动"超链接的时候
		pageList(1,2);

		/*--------------------------------------------------------------------------------*/
		//当用户点击条件查询的按钮时，需要刷新市场活动列表，调用pageList方法,表示用户需要进行条件查询
		$("#searchBtn").click(function () {
            //为了防止搜索与下一页的错误问题，在用户单击查询按钮的时候，保存用户在条件框中输入的信息(使用隐藏域的方式保存)
			//因为用户点击下一页的时候会从新调用pageList方法
            $("#hidden-owner").val($.trim($("#search-owner").val()));
            $("#hidden-name").val($.trim($("#search-name").val()));
            $("#hidden-startDate").val($.trim($("#search-startDate").val()));
            $("#hidden-endDate").val($.trim($("#search-endDate").val()));

			pageList(1
					,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
		})

        /*-------------------------------------------------------------------------------*/
        //关于市场活动的复选框操作
        $("#qx").click(function(){
            //当用户点击全选框后，则下面的单选框都要被选中
            /*
                $("选择器的类型[属性名=属性值]")
                表示的是选择该类型的某一个属性等于某一个值的对象
                  如：下面这个例子，代表的是选择name=xz的input标签
                 选择器.prop方法(“要设置的属性”,true/false):设置或返回被选元素的属性和值
                  如：下面的例子，表示设置name=xz的input标签的checked即选中属性，为当前选择框，即
                     id为qx框的checked状态
             */
            $("input[name=xz]").prop("checked",this.checked);
        })
        //当用户没有全选，或者在下面全选后，对应的上面的全选框应该随之改变
        /*
           通过测试，可以发现这种方法并没有起作用，当我们点击了任意一个或多个单选框之后，并没有弹出
           123，这就代表了选择器没有被触发，这时因为我们每一条市场活动数据，都是动态拼接生成的，对于
           动态拼接生成的元素，我们不能这样进行绑定事件，应该使用on的方式

           语法：$(需要绑定元素的有效的外层元素).on(“绑定事件的方式”,需要绑定的元素的jquery对象,回调函数)
             注意：这个最有效的外层元素不能是动态生成的
         */
        /*$("input[name=xz]").click(
            alert(123);
        )*/
        $("#activityBody").on("click",$("input[name=xz]"),function () {
            /*
               根据下面的复选框被选择的数量，进行判断上面的全选框有没有被选择
                即：复选框的数量=被选择的复选框的数量
             */
            $("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length);
        })

        /*--------------------------------------------------------------------------------------*/
        //市场活动的删除操作
        $("#deleteBtn").click(function () {

            //获取用户选择了哪些要删除的复选框
            var $xz = $("input[name=xz]:checked");

            //判断用户是否选择了复选框，根本的方法时检测$xz的length属性
            if ($xz.length>0){

            	if(confirm("你确定要删除所选记录吗，注意：删除后不可撤回")){
					//如果用户选择了要删除的复选框
					/*
                       我们知道，用户选择的可能是一条，也可能是多条，如果这种方式的话，就不适合使用JSON去传递
                       这个复选框的id，因为JSON中的key是不能重复的，由此，我们以前学过，当同一个key下有多个value时，应该使用传统
                       请求的方式
                          url：workbench/activity/delete.do?id=xxx&id=xxx&id=xxx
                        那么这个参数就需要拼接
                     */
					var param = "";  //定义变量，用于拼接参数

					//将$xz中的每一个dom对象遍历出来，取其value值，就相当于取得了需要删除的记录的id
					for (var i=0;i<$xz.length;i++){
						//获取这个数组中每一个value值
						/*
                           jQuery数组中的每一个元素是一个dom对象，我们可以通过两种方式获取value属性
                             1、dom对象.value      $xz[i].value
                             2、jQuery对象.val()   $($xz[i]).val()
                         */
						param += "id="+$($xz[i]).val();

						//我们需要在每一个id后面加一个&符号，除了最后一个
						if(i<$xz.length-1){
							param+="&"
						}

					}
					//alert(param);
					//程序走到这里parm已经拿到了要删除的id，这时候由于删除之后，页面要局部刷新，我们要使用ajax请求
					$.ajax({
						url:"workbench/activity/delete.do",
						data:param,
						type:"post",  //添加使用post请求
						dataType:"json",
						success:function (data) {
							//前端需要后端返回来的，只需要删除是否成功的标志即可
							/*
                               {“success”:true/false}
                            */
							if(data.success){

								//如果删除成功，则需要局部刷新市场活动信息列表 回到第一页，维持每页展现的记录数
								pageList(1,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

							}else {
								alert("删除市场活动失败");
							}
						}
					})
				}

            } else{
                alert("请先选择你要删除的元素");
            }
        })
		/*-------------------------------------------------------------*/
		//市场活动的修改操作
		$("#editBtn").click(function () {

			//获取用户打对号的全选框，一次只能修改一个市场活动
			var $xz = $("input[name=xz]:checked");

			if($xz.length==0){

				alert("请选择你要修改的记录");

			}else if($xz.length>1){

				alert("一次只能修改一条记录");

			}else{

				/*
				   当用户单击打开模态窗口的时，需要从数据库中先取得两部分信息铺到修改模态窗口的信息栏中
				      1、市场活动的所有者    user对象，可能不止一个
				      2、市场活动的具体信息  Activity对象
				    获取完信息后，应该局部刷新到页面中的标签中
				 */
				/*
				 获取这个市场活动的id，传递给后端，让后端知道要铺哪个市场活动的信息，由于一次只能修改一个
                 市场活动，所以 $xz.val()肯定是正确的，因为他不是数组
                */
				var id = $xz.val();
				$.ajax({
					url:"workbench/activity/getUserListAndActivity.do",
					data:{
						"id":id
					},
					type:"get",
					dataType:"json",
					success:function (data) {
						/*
						   需要后端返回的数据应该是一个所有者的user集合和
						   要修改的该市场活动的详细信息
						   {
						     "uList":[{用户1},{用户2}...],
						     "a":{市场活动信息}
						   }
						 */
						//得到数据后，应该向页面铺数据
						//1、使用循环，将所有者铺到对应的下拉列表上
						var owner="";
						$.each(data.uList,function (i,n) {
							owner +="<option value='"+n.id+"'>"+n.name+"</option>"
						})
						$("#edit-owner").html(owner);

						//将用户选择的市场活动对应的信息铺上，因为一次只能修改一个市场活动，所以不用循环
						/*
						   这个id是存放在隐藏域中的，对于用户没有任何作用，因为id标识着唯一的一条市场活动
						   当我们点击修改，执行修改操作的时候，后台怎么知道我们修改哪一个？
						     通过这个id隐藏域的val值
						 */
						$("#edit-id").val(data.a.id);
						$("#edit-name").val(data.a.name);
						$("#edit-startDate").val(data.a.startDate);
						$("#edit-endDate").val(data.a.endDate);
						$("#edit-cost").val(data.a.cost);
						$("#edit-description").val(data.a.description);

						/*
						  我们可能会好奇，这个select根标签没有value属性，怎么设置值呢
						   select.val(值)
						  这个“值”如果是option的id的话，就会选择这个这个option子标签的文本值
						 */
						$("#edit-owner").val(data.a.owner);

						//铺好之后，显示模态窗口
						$("#editActivityModal").modal("show");
					}
				})
			}

		})

		/*-------------------------------------------------------------------------------*/
		//当用户点击了确认修改按钮
		$("#updateBtn").click(function () {

			//发送ajax请求，将用户填写的数据发送给后端的controller
			$.ajax({
				url:"workbench/activity/update.do",
				data:{
					/*
                      为了防止用户输入的时候带空格，所以要去除前后的空格
                      使用jQuery的$.trim(参数)方法
                     */
					"id":$("#edit-id").val(),
					"owner" : $.trim($("#edit-owner").val()),
					"name" : $.trim($("#edit-name").val()),
					"startDate" : $.trim($("#edit-startDate").val()),
					"endDate" : $.trim($("#edit-endDate").val()),
					"cost" : $.trim($("#edit-cost").val()),
					"description" : $.trim($("#edit-description").val())
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					/*
                       前端需要得到的是在数据库中修改是否成功的标志
                        {"success",true/false}
                     */
					if(data.success){

						//当用户修改成功后
						//1、局部刷新页面的显示
						/*
						   注意：当用户点击了确认修改按钮的时候，如果还是使用以前的pageList(1,2)的方式的话，则用户显示出来的
						   市场活动信息页，会恢复到从第一页开始，每页显示两条记录，即刷新了用户自定义每页展现的记录条数和用户修改所
						   在的页。

						   所以对于增删改查：
						     增加：添加完成后，应该回到第一页(因为后添加的记录在前)，并维持每页展现的记录条数
						     修改：修改完成后应该维持在当前页，并维持用户展现的记录条数
						     删除：应该回到第一页，维持每页展现的记录条数

						   关键代码分析：
						     	pageList($("#activityPage").bs_pagination('getOption', 'currentPage')
										,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

							 $("#activityPage").bs_pagination('getOption', 'currentPage'):停留在当前页
							 $("#activityPage").bs_pagination('getOption', 'rowsPerPage')：维持每页展现的记录条数
						 */
						pageList($("#activityPage").bs_pagination('getOption', 'currentPage')
								,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
						//2、关闭创建市场活动模态窗口
						$("#editActivityModal").modal("hide");


					}else{
						alert("修改失败！");
					}
				}

			})

		})



	});

  /*
	对于所有的关系型数据库，做前端的分页相关操作的基础组件
	就是pageNo和pageSize
	  pageNo:页码
	  pageSize:每页展现的记录数


	pageList方法：就是发出ajax请求到后台，从后台取得最新的市场活动信息列表数据
	通过响应回来的数据，局部刷新市场活动信息列表

	我们都在哪些情况下，需要调用pageList方法（什么情况下需要刷新一下市场活动列表）
	    （1）点击左侧菜单中的"市场活动"超链接，需要刷新市场活动列表，调用pageList方法
		（2）添加，修改，删除后，需要刷新市场活动列表，调用pageList方法
		（3）点击查询按钮的时候，需要刷新市场活动列表，调用pageList方法
		（4）点击分页组件的时候，调用pageList方法

	以上为pageList方法制定了六个入口，也就是说，在以上6个操作执行完毕后，我们必须要调用pageList方法，刷新市场活动信息列表
   */
		function pageList(pageNo,pageSize){

        //将全选的复选框的√干掉
        $("#qx").prop("checked",false);

	    //查询前，将隐藏域中的数据取出来，重新放到搜索框中
        $("#search-name").val($.trim($("#hidden-name").val()));
        $("#search-owner").val($.trim($("#hidden-owner").val()));
        $("#search-startDate").val($.trim($("#hidden-startDate").val()));
        $("#search-endDate").val($.trim($("#hidden-endDate").val()));

		//当我们调用这个方法的时候，代表业务需要向后台的数据库中查询市场活动表的一些信息，在页面的部分区域显示，所以要使用局部刷新的技术
		$.ajax({
			url:"workbench/activity/pageList.do",
			data:{
				/*
				   我们要往后端传什么参数信息？
				      1、分页的页码pageNO：用于计算pageStart(即忽略几条记录) limit pageStart,pageSize
				      2、每页展现的记录数 pageSize
				      3、用户还有可能在上面的查询页面中输入查询条件
				            名称 search-name
				            所有者 search-owner
				            开始日期 search-starDate
				            结束日期 search-endDate
				   对于3：用户可能只输入一部分条件或者不输入条件点击查询，为了适应这种不同的情况，在后台的mybaits我们
				     要使用动态sql的机制
				 */
				"pageNo" : pageNo,
				"pageSize" : pageSize,
				"name" : $.trim($("#search-name").val()),  //去除前后空白，防止用户手误输入空格
				"owner" : $.trim($("#search-owner").val()),
				"starDate" : $.trim($("#search-startDate").val()),
				"endDate" : $.trim($("#search-endDate").val())

			},
			type:"get",
			dataType:"json",
			success:function (data) {
				/*
				   当查查询成功后，前端需要向后端要什么东西呢？
				     1、查询的结果 tbl_activity表中的
				          id(作为复选框的value)、owner(多表查询t_user)、startDate、endDate

				      由于这里的所有者(owner)，在tbl_activity中是用户的编号，而展示的是用户的姓名，所以我们要进行多表联查

				      这样的话，虽然没有一个实体类来保存 1 的查询的结果，
				        但是我们知道Activiry和 我们要返回的数据只是owner不同，
				        tbl_activity中的owner存放的是32为的UUID
				       而我们要的是UUID对应的姓名，这个姓名完全可以存放在Activity实体类的owner字段中
				      所以我们使用
				        List<Activity> aList保存即可
				       {“dataList”：aList}

				     2、我们还要使用一个分页插件，插件中要使用到一个参数：查询出来的总条数
				          total
				    结合这两点来看，返回的json形式应该为
				     {
				       "total":?,
				       "dataList":[{市场活动信息1,2,3....}]
				      }
				 */
				var html="";
				//循环查询出来的1，即循环查询出来的市场信息列表
				/*
				   这里不能直接循环data，因为data.dataList才是返回的市场活动信息数组的json
				 */
				$.each(data.dataList,function (i,n) {
					/*
					   关于字符串的拼接问题
					     ’‘里面可以包含双引号，“”里面可以包含''单引号，当’‘里面包含单引号，或者“”里面包含双引号的时候
					       要使用转义字符
					         ' \' ' 或  " \" "
					 */
					html += '<tr class="active">';
					html += '<td><input type="checkbox" name="xz" value="'+n.id+'"/></td>';
					html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/activity/detail.do?id='+n.id+'\';">'+n.name+'</a></td>';
					html += '<td>'+n.owner+'</td>';
					html += '<td>'+n.startDate+'</td>';
					html += '<td>'+n.endDate+'</td>';
					html += '</tr>';
				})

				//更新activityBody的数据
				$("#activityBody").html(html);

		        //添加分页操作的组件,让用户可以使用分页操作
				var totalPages=data.total%pageSize==0?(data.total/pageSize):parseInt(data.total/pageSize)+1;
				$("#activityPage").bs_pagination({
					currentPage: pageNo, // 页码
					rowsPerPage: pageSize, // 每页显示的记录条数
					maxRowsPerPage: 20, // 每页最多显示的记录条数
					totalPages: totalPages, // 总页数
					totalRows: data.total, // 总记录条数

					visiblePageLinks: 3, // 显示几个卡片

					showGoToPage: true,
					showRowsPerPage: true,
					showRowsInfo: true,
					showRowsDefaultInfo: true,
                    /*当用户点击了分页组件后，会自动触发pageList*/
					onChangePage : function(event, data){
						pageList(data.currentPage , data.rowsPerPage);
					}
				});

			}
		})

	}
</script>
</head>
<body>

    <!--
      四个隐藏域，分别对应用户条件查询的四个条件
        目的是为了保存用户上一次点击查询，输入的对应条件
    -->
    <input type="hidden" id="hidden-name"/>
    <input type="hidden" id="hidden-owner"/>
    <input type="hidden" id="hidden-startDate"/>
    <input type="hidden" id="hidden-endDate"/>

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form id="activityAddForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">

								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-name">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<!--在开始日期中加入事件控件 并将输入框设置为只读，不允许修改-->
								<input type="text" class="form-control time" id="create-startDate" readonly>
							</div>
							<label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<!--在结束日期中加入事件控件  并将输入框设置为只读，不允许修改-->
								<input type="text" class="form-control time" id="create-endDate" readonly>
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<!--
					   data-dismiss="modal" 表示关闭模态窗口，当我们点击保存或者关闭的时候，都会关闭模态窗口
					   但注意：当我们点击保存的时候，不仅仅要关闭模态窗口，也要将用户输入的数据添加到数据库中，
					   所以不能将属性写死在 按钮标签中，必须为其指定一个id，通过js来操作这个click事件
					-->
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveBtn">保存</button>
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
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">

						<!--存放修改市场活动id的隐藏域-->
						<input type="hidden" id="edit-id"/>
					
						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">
								  <%--<option>zhangsan</option>
								  <option>lisi</option>
								  <option>wangwu</option>--%>
								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-name">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-startDate" readonly>
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-endDate" readonly>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<!--
								   关于textarea需要注意的点：
								     1）一定是要以标签对的形式来呈现,正常状态下标签对要紧紧的挨着，因为标签内的东西，包括空格都是文本内容
								        的一部分
									 2）textarea虽然是以标签对的形式来呈现的，但是它也是属于表单元素范畴
									    我们所有的对于textarea的取值和赋值操作，应该统一使用val()方法（而不是html()方法）
								-->
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	<!--用户的条件查询输入条件的地方-->
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control" type="text" id="search-startDate" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control" type="text" id="search-endDate">
				    </div>
				  </div>
					<!--
					   在前面我们介绍过，提交按钮的属性不能为submit因为，如果使用的是submit点击之后，会立即提交表单
					   所以我们要把type设置为button，为其添加id，使用jQuery判断其单击事件来发送ajax请求
					-->
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
					<!--
					   创建新市场活动的按钮，使用了模态窗口的技术
					     data-toggle="modal"：表示出发该按钮，将要打开模态窗口
					     data-target="#createActivityModal"：表示要打开哪个模态窗口，通过#id的形式找到该窗口
					     data-dismiss="modal"  表示关闭模态窗口

					    我们这种方式把两种属性都放在了button的属性中，这样有一个缺点：
					      当点击了这个按钮后，将会立即打开模态窗口，无法在点击这个按钮后先执行某个操作再打开模态窗口
					      即没有办法对按钮的功能进行扩充
					    未来的实际开发中，对于触发模态窗口的操作不要写死在按钮中，要使用js代码控制
					-->
				  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox"  id="qx"/></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="activityBody">

					</tbody>
				</table>
			</div>

		<!--
		   在这个div标签内引入bootstrap分页插件
		-->
		<div style="height: 50px; position: relative;top: 30px;">
			<!--
			  在这个div内显示分页插件
			-->
			<div id="activityPage"></div>
		</div>
		
	  </div>
	</div>
</body>
</html>