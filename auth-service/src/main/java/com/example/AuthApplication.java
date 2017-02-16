package com.example;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;
import org.springframework.cloud.netflix.hystrix.EnableHystrix;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.oauth2.config.annotation.configurers.ClientDetailsServiceConfigurer;
import org.springframework.security.oauth2.config.annotation.web.configuration.AuthorizationServerConfigurerAdapter;
import org.springframework.security.oauth2.config.annotation.web.configuration.EnableAuthorizationServer;
import org.springframework.security.oauth2.config.annotation.web.configuration.EnableResourceServer;
import org.springframework.security.oauth2.config.annotation.web.configurers.AuthorizationServerEndpointsConfigurer;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import java.security.Principal;
import java.util.Optional;
import java.util.stream.Stream;

@SpringBootApplication
@EnableResourceServer
@EnableJpaAuditing
@EnableJpaRepositories
@EnableEurekaClient
@EnableHystrix
public class AuthApplication {

	public static void main(String[] args) {
		SpringApplication.run(AuthApplication.class, args);
	}
}

@RestController
class PrincipalRestController {

	@RequestMapping ("/user")
	Principal principal (Principal principal) {
		return principal;
	}

}

@Configuration
@EnableAuthorizationServer
class OAuthConfiguration extends AuthorizationServerConfigurerAdapter {

	@Autowired
	private AuthenticationManager authenticationManager ;

	@Override
	public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
		clients
				.inMemory()
				.withClient("ipad")
				.secret("ipadsecret")
				.scopes("openid")
				.authorizedGrantTypes(
						"authorization_code", "refresh_token", "password");
	}

	@Override
	public void configure(AuthorizationServerEndpointsConfigurer endpoints) throws Exception {
	 endpoints.authenticationManager(this.authenticationManager);
	}

}

@Service
class UserDetailsServiceImpl implements UserDetailsService {

	private final UserRepository userRepository;

	@Autowired
	public UserDetailsServiceImpl(UserRepository userRepository) {
		this.userRepository = userRepository;
	}

	@Override
	public UserDetails loadUserByUsername(String username) throws
			UsernameNotFoundException {

		return this.userRepository.findByUsername(username)
				.map(user -> new org.springframework.security.core.userdetails.User(
						user.getUsername(),
						user.getPassword(),
						user.isActive(),
						user.isActive(),
						user.isActive(),
						user.isActive(),
						//TODO load roles for the user, for now just assign static
						AuthorityUtils.createAuthorityList("ROLE_ADMIN", "ROLE_USER")))
				.orElseThrow(() -> new UsernameNotFoundException("couldn't find the user " +
						"" + username + "!"));

	}
}

//@Component
//class SampleUserDataCLR implements CommandLineRunner {
//
//	private final UserRepository userRepository;
//
//	@Autowired
//	public SampleUserDataCLR(UserRepository userRepository) {
//		this.userRepository = userRepository;
//	}
//
//	@Override
//	public void run(String... strings) throws Exception {
//
//		Stream.of("user,password", "user1,pass1", "user2,pass2")
//				.map(t -> t.split(","))
//				.forEach(tuple ->
//						userRepository.save(new User(
//								tuple[0],
//								tuple[1],
//								true
//						))
//				);
//
//
//	}
//}

interface UserRepository extends JpaRepository<User, Long> {

	Optional<User> findByUsername(String username);
}

@Entity
class User {

	public User(String username, String password, boolean active) {
		this.username = username;
		this.password = password;
		this.active = active;
	}

	@Id
	@GeneratedValue
	private Long id;

	private String username, password;
	private boolean active;

	public String getUsername() {
		return username;
	}

	User() {
	}

	public String getPassword() {
		return password;
	}

	public boolean isActive() {
		return active;
	}
}
