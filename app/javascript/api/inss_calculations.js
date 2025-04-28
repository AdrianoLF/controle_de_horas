import apiClient from "./index";

export const calculateDiscount = (salary) =>
  apiClient.post(`/inss_calculations/discount`, { salary });
