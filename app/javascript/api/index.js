import axios from 'axios';

const apiClient = axios.create({
  baseURL: 'http://localhost:3000/api/v1',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  }
});

// Interceptor para adicionar o token do Vuex
apiClient.interceptors.request.use(
  (config) => {
    config.headers['Authorization'] = localStorage.auth_token;
    return config;
  },
  (error) => Promise.reject(error)
);

apiClient.interceptors.response.use(
  (response) => {
    return response.data; // Retorna apenas o corpo da resposta
  },
  (error) => {
    // Opcional: Você pode adicionar lógica de tratamento de erros aqui
    return Promise.reject(error);
  }
);

export default apiClient;