/**
 * Created with JetBrains RubyMine.
 * User: eric
 * Date: 12-12-19
 * Time: 下午4:04
 * To change this template use File | Settings | File Templates.
 */

//************************************************//
//tab 隔行换色 鼠标移过换色
$(document).ready(function() {
    // 给class为datatable的表格的偶数行添加class值为alt
    $(".tabinfo  tr:even").addClass("alt");
    // 如果鼠标移到class为datatable的表格的tr上时，执行函数
    $(".tabinfo tr").mouseover(function() {
        // 给这行添加class值为over，并且当鼠标一出该行时执行函数
        $(this).addClass("over");
    }).mouseout(function() {
            // 移除该行的class
            $(this).removeClass("over");
        });
    $("button").mouseover(function() {
        // 给这行添加class值为over，并且当鼠标一出该行时执行函数
        $(this).css("background-color","#91cb8d");
    }).mouseout(function() {
            // 移除该行的class
            $(this).css("background-color","");
        });
});
