package com.transportation.metrobas.auth;

import com.transportation.metrobas.enums.Role;
import com.transportation.metrobas.exception.EmailAlreadyExist;
import com.transportation.metrobas.exception.PasswordNotMatch;
import com.transportation.metrobas.user.User;
import com.transportation.metrobas.user.UserAdabter;
import com.transportation.metrobas.user.UserDto;
import com.transportation.metrobas.user.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final JwtService jwtService;

    private final UserRepository userRepository;

    private final UserAdabter userAdabter;

    private final PasswordEncoder passwordEncoder;

    private final AuthenticationManager authenticationManager;

    @Autowired
    public AuthService(JwtService jwtService, UserRepository userRepository, UserAdabter userAdabter, PasswordEncoder passwordEncoder, AuthenticationManager authenticationManager) {
        this.jwtService = jwtService;
        this.userRepository = userRepository;
        this.userAdabter = userAdabter;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
    }

    public void register(RegisterRequest registerRequest){

        if(userRepository.findByUserNameOrEmail(registerRequest.getUserName(), registerRequest.getEmail()).isPresent()){
            throw new EmailAlreadyExist("email or user name is already exist");
        }

        if(!registerRequest.getPassword().equals(registerRequest.getConfirmPassword())){
            throw new PasswordNotMatch("password not match confirmed password");
        }

        User user = new User(registerRequest.getFirstName(),
                registerRequest.getLastName()
                ,registerRequest.getEmail(),
                passwordEncoder.encode(registerRequest.getPassword()),
                registerRequest.getPhone(),
                registerRequest.getUserName(),
                Role.USER,
                registerRequest.getAge(),
                registerRequest.getGender());

        user.setEnabled(true);
        userRepository.save(user);
    }

    public LoginResponse login(LoginRequest loginRequest) {

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginRequest.getUserName(),
                        loginRequest.getPassword()
                )
        );

        User user = userRepository.findByUserNameOrEmail(loginRequest.getUserName(), loginRequest.getUserName()).orElseThrow();

        String jwt = jwtService.generateToken(user);

        userRepository.save(user);

        UserDto userDto = userAdabter.UserToDto(user);

        return new LoginResponse(jwt, userDto);
    }


    @Transactional
    public void changePassword(ChangePasswordDto changePasswordDto, String userName){
        User user = userRepository.findByUserName(userName).orElseThrow();

        if (!passwordEncoder.matches(changePasswordDto.getCurrentPassword(), user.getPassword())) {
            throw new RuntimeException("Current password is incorrect");
        }

        if (!changePasswordDto.getNewPassword().equals(changePasswordDto.getConfirmNewPassword())) {
            throw new PasswordNotMatch("New password does not match confirmed password");
        }

        user.setPassword(passwordEncoder.encode(changePasswordDto.getNewPassword()));
        userRepository.save(user);
    }

    @Transactional
    public void blockUser(int userId){
        User user = userRepository.findById(userId).orElseThrow();
        user.setEnabled(false);
        userRepository.save(user);
    }
}
