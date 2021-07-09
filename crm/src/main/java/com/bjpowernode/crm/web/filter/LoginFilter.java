package com.bjpowernode.crm.web.filter;

import com.bjpowernode.crm.settings.domain.User;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * 防止用户恶意登录的过滤器
 *  需求：当用户企图在url栏中直接访问目标资源时，对其过滤
 */
public class LoginFilter implements Filter {
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {

        System.out.println("进入用户登录过滤页面：判断用户是否是恶意登录");

        //取得request和response对象
        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        //取得用户访问的地址，如果是login.jsp和/settings/user/login.do就不用过滤，因为用户正在进行验证
        String path = request.getServletPath();

        //判断用户访问的地址是否是关于登录验证的资源
        if("/login.jsp".equals(path) || "/settings/user/login.do".equals(path)){

            filterChain.doFilter(servletRequest,servletResponse);

        }else{   //用户访问的是不是验证登录的资源

            HttpSession session =  request.getSession();
            User user = (User) session.getAttribute("user");

            if(user != null){

                filterChain.doFilter(servletRequest,servletResponse);

            }else {

                response.sendRedirect("/crm/login.jsp");
                //request.getRequestDispatcher("/login.jsp").forward(request,response);

            }

        }
    }
}
