---
title: Donate
description: "饿死了，没钱吃饭，大佬给点钱钱吧"
draft: false
displayInMenu: true
displayInList: false
dropCap: false
---

<style type="text/css">@import 'https://cdn.datatables.net/1.10.16/css/jquery.dataTables.min.css';</style>
<script src="https://cdn.datatables.net/1.10.16/js/jquery.dataTables.min.js"></script>
<script type="text/javascript">
	donate_app_id = 31;
	jQuery(document).ready(function($) {
		$('#donation_table').DataTable({
			"ajax": {
				'url': 'https://accounts.extstars.com/api/v2/donation/pull',
				'type': 'POST',
				'data': function(d) {
					d.limit = 300;
					d.order_type = 3;
				},
				'beforeSend': function(request) {
					request.setRequestHeader("AppId", donate_app_id);
				},
				'dataFilter': function(data) {
					var msg = $.parseJSON(data);
					var new_data_array = {};
					new_data_array["data"] = [];
					for (var index in msg.data) {
						new_data_array["data"].push(["<img src='" + msg.data[index]['avatar_url'] + "'/>", msg.data[index]['user_name'], msg.data[index]['amount']]);
					}
					var new_data = JSON.stringify(new_data_array);
					return new_data;
				}
			}
		});
		var url_string = window.location.href;
		var url = new URL(url_string);
		var amount = url.searchParams.get("amount");
		if(amount != null) {
				alert("感谢您的捐赠！");
		}
	});
</script>

<script type="text/javascript" src="https://files.extstars.com/assets/js/qrcodejs/qrcode.js"></script>
<script type="text/javascript" src="https://files.extstars.com/assets/js/donate.js"></script>

<div class="container">
	<h3 class="comment-reply-title">欢迎捐赠 </h3>
	<div class="row">
		<div class="col-sm-12">
			<div class="form-group"><input type="text" class="form-control" name="author" id="author" value="" placeholder="姓名" aria-required="true" required="" /></div>
		</div>
		<div class="col-sm-12">
			<div class="form-group"><input type="email" class="form-control" name="email" id="email" value="" placeholder="电子邮件（不会被公开）" aria-required="true" /></div>
		</div>
		<div class="col-sm-12">
			<div class="form-group"><input type="url" class="form-control" name="url" id="url" value="" placeholder="站点" /></div>
		</div>
		<div class="col-sm-12">
			<div class="form-group"><input type="text" class="form-control" name="amount" id="amount" value="" placeholder="金额/元" aria-required="true" required="" /></div>
		</div>
		<div class="col-sm-12">
			<div class="form-group">
				<select class="form-control" name="pay_method" id="pay_method">
						<option value="alipay">支付宝</option>
						<option value="wechat">微信扫码支付</option>
						<option value="wechat_h5">微信唤起支付(请在手机的默认浏览器使用)</option>
						<option value="qqpay">QQ扫码支付</option>
						<option value="paypal">Paypal</option>
					</select>
			</div>
		</div>
	</div>
	<p class="form-submit">
		<button name="btn-submit" id="btn-submit" class="submit">捐赠</button>
	</p>
	<div id="div_qrcode_show"></div>
</div>

<div class="container">
	<h3 class="comment-reply-title">捐赠记录 </h3>
	<table id="donation_table" class="display" style="width:100%">
		<thead>
			<tr>
				<th>头像</th>
				<th>昵称</th>
				<th>金额</th>
			</tr>
		</thead>
		<tfoot>
			<tr>
				<th>头像</th>
				<th>昵称</th>
				<th>金额</th>
			</tr>
		</tfoot>
	</table>
</div>
