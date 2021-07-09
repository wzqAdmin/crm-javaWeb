package com.bjpowernode.crm.web.filter;

import javax.servlet.*;
import java.io.IOException;

/**
 * 用于处理servlet post请求协议包中乱码
 *     处理response响应的乱码问题
 */
public class EncodingFilter implements Filter {

    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chan) throws IOException, ServletException {
        //处理请求协议包post请求的解码类型
        req.setCharacterEncoding("utf-8");

        //处理response默认的解码类型
        resp.setContentType("text/html;charset=utf-8");

        //放行过滤器
        chan.doFilter(req,resp);
    }
}
