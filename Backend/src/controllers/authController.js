const { registerUser, loginUser } = require("../services/authService");

async function register(req, res, next) {
  try {
    const user = await registerUser(req.body);
    res.status(201).json({
      message: "User registered successfully.",
      user,
    });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    next(error);
  }
}

async function login(req, res, next) {
  try {
    const data = await loginUser(req.body);
    res.status(200).json({
      message: "Login successful.",
      token: data.token,
      user: data.user,
    });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    next(error);
  }
}

module.exports = {
  register,
  login,
};