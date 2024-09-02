package com.transportation.metrobas.auth;

import com.transportation.metrobas.user.User;
import com.transportation.metrobas.user.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.logout.LogoutHandler;

@Configuration
public class CustomLogoutHandler implements LogoutHandler {

    private final JwtService jwtService;

    private final UserRepository userRepository;

    @Autowired
    public CustomLogoutHandler(JwtService jwtService, UserRepository userRepository) {
        this.jwtService = jwtService;
        this.userRepository = userRepository;
    }

    @Override
    public void logout(HttpServletRequest request, HttpServletResponse response, Authentication authentication) {
        String authHeader = request.getHeader("Authorization");

        if(authHeader == null || !authHeader.startsWith("Bearer ")) {
            return;
        }

        String token = authHeader.substring(7);

        String userName = jwtService.extractUsername(token);
        if(userName == null){
            return;
        }

        userRepository.findByUserName(userName).ifPresent(userRepository::save);

    }
}
