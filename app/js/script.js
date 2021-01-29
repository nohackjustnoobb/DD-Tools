var players = [];
var channel_info = {};
var saved_channel_id = [];
var request_timeout = undefined;

window.onresize = player_size_update;
icon = document.getElementsByClassName("icon");
for (var i = 0; i < icon.length; i++) {
    icon[i].setAttribute("onmousedown", "mousedown(this)");
    icon[i].setAttribute("onmouseup", "mouseup(this)");
}

function mousedown(element) {
    element.classList.add("mousedown");
}

function mouseup(element) {
    element.classList.remove("mousedown");
}

function get_channel_info(channel_id) {
    if (channel_info[channel_id]) {
        return false;
    }
    var channel_data = $.get("https://www.youtube.com/channel/" + channel_id).done(() => {
        var string_data = channel_data.responseText;
        var start_index = string_data.indexOf("\"", string_data.indexOf("og:title") + 9);
        var end_index = string_data.indexOf("\"", start_index + 1);
        var channel_name = string_data.slice(start_index + 1, end_index);
        start_index = string_data.indexOf("\"", string_data.indexOf("image_src") + 10);
        end_index = string_data.indexOf("\"", start_index + 1);
        var channel_icon_url = string_data.slice(start_index + 1, end_index);
        start_index = string_data.indexOf("\"", string_data.indexOf("banner") + 30);
        end_index = string_data.indexOf("\"", start_index + 1);
        var banner_url = string_data.slice(start_index + 1, end_index);
        channel_info[channel_id] = [channel_name, channel_icon_url, banner_url];
    })
    return channel_data;
}

function _addchannel(bg_url, channel_icon_url, stream_id, channel_name_) {
    if (document.getElementById(stream_id)) {
        return;
    }
    var bg = new Image();
    bg.src = bg_url;
    bg.classList.add("channelbg");
    var channel_icon = new Image();
    channel_icon.src = channel_icon_url;
    channel_icon.classList.add("channel_icon");
    var channel_name = document.createElement("span");
    channel_name.innerHTML = channel_name_;
    channel_name.classList.add("channel_name");
    var preview = document.createElement("div");
    preview.id = stream_id;
    preview.classList.add("preview")
    preview.appendChild(bg);
    preview.appendChild(channel_icon);
    preview.appendChild(channel_name);
    channel_icon.setAttribute("onclick", "tooggle_player(this)");
    bg.setAttribute("onclick", "tooggle_player(this)");
    preview.setAttribute("onmousedown", "mousedown(this)");
    preview.setAttribute("onmouseup", "mouseup(this)");
    preview.innerHTML += "<i class=\"fas fa-times-circle\" onclick=close_channel(this)></i><i class=\"fas fa-comments\" onclick=toggle_stream_comment(this)></i>";
    $("#addstream").before(preview);
    return;
}

function check_stream(channel_id, addpreview = false) {
    function stream() {
        var data = $.get("https://www.youtube.com/channel/" + channel_id).done(() => {
            var string_data = data.responseText;
            var start_index = string_data.indexOf("hqdefault_live");
            if (start_index != -1) {
                var match = true;
                start_index -= 200;
            } else {
                var match = false;
            }
            start_index = string_data.indexOf("\"", string_data.indexOf("videoId", start_index) + 9);
            end_index = string_data.indexOf("\"", start_index + 1);
            var stream_id = string_data.slice(start_index + 1, end_index)
            start_index = string_data.indexOf("\"", string_data.indexOf("url", end_index) + 5);
            end_index = string_data.indexOf("\"", start_index + 1);
            var stream_thumbnails_url = string_data.slice(start_index + 1, end_index);
            var start_index = string_data.indexOf("\"", string_data.indexOf("og:title") + 9);
            var end_index = string_data.indexOf("\"", start_index + 1);
            var channel_name = string_data.slice(start_index + 1, end_index);
            start_index = string_data.indexOf("\"", string_data.indexOf("image_src") + 10);
            end_index = string_data.indexOf("\"", start_index + 1);
            var channel_icon_url = string_data.slice(start_index + 1, end_index);
            start_index = string_data.indexOf("\"", string_data.indexOf("banner") + 30);
            end_index = string_data.indexOf("\"", start_index + 1);
            var banner_url = string_data.slice(start_index + 1, end_index);
            channel_info[channel_id] = [channel_name, channel_icon_url, banner_url];
            if (match) {
                _addchannel(stream_thumbnails_url, channel_info[channel_id][1], stream_id, channel_info[channel_id][0]);
            } else {
                var channel_list = document.getElementsByClassName("preview");
                for (var i = 0; i < channel_list.length; i++) {
                    if (channel_list[i].children[1].currentSrc == channel_info[channel_id][1]) {
                        close_channel(channel_list[i].children[channel_list[i].children.length - 2]);
                    }
                }
            }
            if (addpreview) {
                add_channel_preview(channel_id);
            }
        });
    }
    var index = channel_id.indexOf("channel");
    if (index != -1) {
        var lastindex = channel_id.lastIndexOf("/")
        if (lastindex > index + 8) {
            channel_id = channel_id.slice(index + 8, lastindex);
        } else {
            channel_id = channel_id.slice(index + 8, channel_id.length + 1);
        }
    }
    stream();
}

function add_channel() {
    var link = document.getElementById("addstreaminterfaceinput").value;
    var channel_id;
    var index = link.indexOf("channel");
    if (index != -1) {
        var lastindex = link.lastIndexOf("/")
        if (lastindex > index + 8) {
            channel_id = link.slice(index + 8, lastindex);
        } else {
            channel_id = link.slice(index + 8, link.length + 1);
        }
        check_stream(channel_id, false);
        close_addstreaminterface()
        document.getElementById("addstreaminterfaceinput").value = "";
        return;
    } else {
        var index = link.indexOf("watch");
        if (index != -1) {
            var video_id = link.slice(index + 8, link.length);
        } else {
            var video_id = link;
        }
        var videos_info = $.get("https://www.youtube.com/watch?v=" + video_id).done(() => {
            var string_data = videos_info.responseText;
            var start_index = string_data.indexOf("\"", string_data.indexOf("channelId") + 11);
            var end_index = string_data.indexOf("\"", start_index + 1);
            var channel_id = string_data.slice(start_index + 1, end_index);
            check_stream(channel_id, false);
            close_addstreaminterface()
            document.getElementById("addstreaminterfaceinput").value = "";
            return;
        })
    }
}

function close_addstreaminterface() {
    document.getElementById("setting_bg").style.display = "none";
    document.getElementById("addstreaminterface").style.display = "none";
}

function open_addstreaminterface() {
    document.getElementById("addstreaminterface").style.display = "block";
    document.getElementById("setting_bg").style.display = "block";
}

function close_channel(close_icon) {
    close_icon.parentElement.remove();
    if (document.getElementById("_" + close_icon.parentElement.id)) {
        $("#_" + close_icon.parentElement.id).remove();
        player_size_update();
    }
}

function tooggle_player(channel) {
    channel = channel.parentElement;
    var video_id = channel.id;
    if (document.getElementById("_" + video_id)) {
        $("#_" + video_id).remove();
        channel.classList.remove("activate");
        document.getElementById(video_id).children[document.getElementById(video_id).children.length - 1].style.display = "none";
        channel.children[channel.children.length - 1].style.borderColor = "rgba(243, 85, 85, 0.7)";
        player_size_update();
        return;
    }
    var player_div = document.createElement("div");
    player_div.id = "_" + video_id;
    player_div.classList.add("player_div")
    var player = document.createElement("div");
    player.classList.add("player");
    player.id = "player_" + video_id;
    player_div.appendChild(player);
    document.getElementById("display").appendChild(player_div);
    var player_ = new YT.Player(player.id, {
        videoId: video_id,
        events: {
            'onReady': onPlayerReady
        }
    });
    players.push(player_);
    player_size_update();
    channel.classList.add("activate");
    document.getElementById(video_id).children[document.getElementById(video_id).children.length - 1].style.display = "block";
    return;
}

function toggle_stream_comment(channel) {
    var video_id = channel.parentElement.id;
    var player_div = document.getElementById("_" + video_id);
    var div_width = Number(player_div.style.width.slice(0, player_div.style.width.length - 2));
    var div_height = player_div.style.height.slice(0, player_div.style.height.length - 2);;
    if (document.getElementById("comment_" + video_id)) {
        $("#comment_" + video_id).remove();
        channel.classList.remove("activate_chat");
        document.getElementById("player_" + video_id).width = div_width;
        channel.style.borderColor = "rgba(243, 85, 85, 0.7)";
        return;
    }
    var chat_url = "https://www.youtube.com/live_chat?v=" + video_id;
    var comment_iframe = document.createElement("iframe");
    comment_iframe.setAttribute("frameBorder", "0");
    comment_iframe.id = "comment_" + video_id;
    comment_iframe.src = chat_url;
    comment_iframe.referrerPolicy = "origin";
    player_div.appendChild(comment_iframe);
    comment_iframe.width = div_width / 2.1;
    comment_iframe.height = div_height;
    document.getElementById("player_" + video_id).width = div_width / 1.92;
    channel.style.borderColor = "#00ff00";
}

function onPlayerReady(event) {
    event.target.playVideo();
}

function player_size_update() {
    const players = document.getElementsByClassName("player");
    var fixd_scale1 = 0.79;
    var fixd_scale2 = 0.7;
    if (document.getElementsByClassName("hide")[0]) {
        fixd_scale1 = 0.85;
        fixd_scale2 = 0.8;
        document.getElementById("display").style.transform = "translate(0,-" + document.getElementById("navigation").offsetHeight + "px)";
    } else {
        document.getElementById("display").style.transform = "translate(0, 0)";

    }
    if (!players.length) {
        return;
    }
    var item_per_row = 0;
    var item_per_column = 0;
    for (var i = 1; i <= players.length; i++) {
        if (i * (i - 1) >= players.length) {
            item_per_row = i;
            item_per_column = i - 1;
            break;
        } else if (i ** 2 >= players.length) {
            item_per_row = i;
            item_per_column = i;
            break;
        }
    }
    if (players.length == 2) {
        item_per_row,
        item_per_column = 2;
    }
    var width = window.innerWidth;
    var height = window.innerHeight;
    if (item_per_column == item_per_row) {
        var player_width = width / item_per_row * fixd_scale1;
        var player_height = player_width / 16 * 9;
    } else {
        var player_height = height / item_per_column * fixd_scale2;
        var player_width = player_height * 16 / 9;
    }
    for (i = 0; i <= players.length - 1; i++) {
        players[i].parentElement.style.height = player_height + "px";
        players[i].parentElement.style.width = player_width + "px";
        players[i].height = player_height;
        if (players[i].parentElement.children[1]) {
            players[i].parentElement.children[1].height = player_height;
            players[i].parentElement.children[1].width = player_width / 2.1;
            players[i].width = player_width / 1.92;
        } else {
            players[i].width = player_width;
        }
    }
}

function pause_all_player() {
    for (var i = 0; i < players.length; i++) {
        players[i].pauseVideo();
    }
}

function play_all_player() {
    for (var i = 0; i < players.length; i++) {
        players[i].playVideo();
    }
}

function voice_up() {
    for (var i = 0; i < players.length; i++) {
        players[i].setVolume(players[i].getVolume() + 10);
    }
}

function voice_down() {
    for (var i = 0; i < players.length; i++) {
        players[i].setVolume(players[i].getVolume() - 10);
    }
}

function toggle_fullscreen() {
    if (document.getElementsByClassName("fullscreen")[0]) {
        document.exitFullscreen();
        $("#fullicon").removeClass("fullscreen fa-compress");
        $("#fullicon").addClass("fa-expand");
        player_size_update();
        return;
    }
    document.body.requestFullscreen();
    $("#fullicon").addClass("fullscreen fa-compress");
    $("#fullicon").removeClass("fa-expand");
    player_size_update();
}

function hide_navigation() {
    $("#navigation").addClass("hide");
    $("#navigation").css({
        "transition": "top 2s",
        "top": "-" + window.innerHeight + "px"
    });
    $("#show_navigation").css({
        "top": "-50px"
    });
    player_size_update();
}

function show_navigation() {
    $("#navigation").removeClass("hide");
    $("#navigation").css({
        "top": "0px",
        "transition": "top .5s"
    });
    $("#show_navigation").css({
        "top": "-150px"
    });
    player_size_update();
}

function open_setting() {
    document.getElementById("setting").style.display = "block";
    document.getElementById("setting_bg").style.display = "block";
}

function close_setting() {
    document.getElementById("setting").style.display = "none";
    document.getElementById("addstreaminterface").style.display = "none";
}

function toggle_channel_setting() {
    if (document.getElementsByClassName("opened_channel_setting")[0]) {
        $("#channel_setting").removeClass("opened_channel_setting");
        document.getElementById("channel_setting").style.minHeight = "50px";
        document.getElementById("channel_arrow").style.transform = "rotate(0deg)";
        return;
    }
    $("#channel_setting").addClass("opened_channel_setting");
    document.getElementById("channel_arrow").style.transform = "rotate(90deg)";
    document.getElementById("channel_setting").style.minHeight = document.getElementById("channel_preview").offsetHeight + 55 + "px";
}

function open_addfollowchannelinterface() {
    $("#addfollowchannelinterface").show();
    setTimeout(function () {
        document.getElementById("setting").setAttribute("onclick", "close_addfollowchannelinterface()");
    }, 100)
}

function close_addfollowchannelinterface() {
    document.getElementById("setting").setAttribute("onclick", "");
    $("#addfollowchannelinterface").hide();
}

function del_channel_preview(channel) {
    var channel_id = channel.id;
    $("#" + channel_id).remove();
    saved_channel_id.splice(saved_channel_id.indexOf(channel.id), 1);
    save_setting();
}

function add_channel_preview(channel_id = undefined) {
    function channel_preview() {
        var channel_icon_url = channel_info[channel_id][1];
        var banner_url = channel_info[channel_id][2];
        var channel_preview_div = document.createElement("div");
        channel_preview_div.classList.add("channel_preview_div");
        channel_preview_div.id = channel_id;
        channel_preview_div.setAttribute("onclick", "del_channel_preview(this)");
        var channel_icon = new Image();
        channel_icon.src = channel_icon_url;
        channel_icon.classList.add("channel_preview_icon");
        var channel_banner = new Image();
        channel_banner.src = banner_url;
        channel_banner.classList.add("channel_preview__bg");
        channel_preview_div.appendChild(channel_banner);
        channel_preview_div.appendChild(channel_icon);
        channel_preview_div.innerHTML += "<div class=\"channel_preview_bg\"><i class=\"fas fa-times-circle\"></i></div>";
        document.getElementById("channel_preview").appendChild(channel_preview_div);
        if (saved_channel_id.indexOf(channel_id) == -1) {
            saved_channel_id.push(channel_id);
            save_setting()
        }
        document.getElementById("channel_setting").style.minHeight = document.getElementById("channel_preview").offsetHeight + 55 + "px";
    }
    if (!channel_id) {
        var channel_link = document.getElementById("addfollowchannelinterfaceinput").value;
        var index = channel_link.indexOf("channel");
        if (index != -1) {
            var lastindex = channel_link.lastIndexOf("/");
            if (lastindex > index + 8) {
                channel_id = channel_link.slice(index + 8, lastindex);
            } else {
                channel_id = channel_link.slice(index + 8, channel_link.length + 1);
            }
        } else {
            channel_id = channel_link;
        }
    }
    if (document.getElementById(channel_id)) {
        document.getElementById("addfollowchannelinterfaceinput").value = "";
        close_addfollowchannelinterface();
        return;
    }
    document.getElementById("addfollowchannelinterfaceinput").value = "";
    var channel = get_channel_info(channel_id);
    if (channel) {
        channel.done(() => {
            channel_preview();
        })
    } else {
        channel_preview();
    }
    close_addfollowchannelinterface();
}

function save_setting() {
    var json_data = {
        "channel_id": saved_channel_id,
        "request_timeout": Number(request_timeout)
    };
    console.log(json_data)
    window.api.save_settings(json_data);
}

function get_setting() {
    var setting = window.api.get_settings();
    saved_channel_id = setting.channel_id;
    request_timeout = setting.request_timeout;
}

function check_following_channel() {
    get_setting();

    function setDelay(i) {
        setTimeout(check_stream, request_timeout * i, saved_channel_id[i - 1], true);
    }
    for (var i = 1; i < saved_channel_id.length + 1; i++) {
        setDelay(i);
    }
}

function toggle_about() {
    if (document.getElementsByClassName("opened_about")[0]) {
        $("#about").removeClass("opened_about");
        document.getElementById("about").style.minHeight = "50px";
        document.getElementById("about_arrow").style.transform = "rotate(0deg)";
        return;
    }
    $("#about").addClass("opened_about");
    document.getElementById("about_arrow").style.transform = "rotate(90deg)";
    document.getElementById("about").style.minHeight = "170px";
}