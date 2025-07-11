import axios from "axios";

const publicApiClient = axios.create({
  baseURL: `${window.location.origin}/api/v1`,
  timeout: 20000,
  headers: {
    "Content-Type": "application/json",
    "Cache-Control": "no-cache",
    Pragma: "no-cache",
    Expires: "0",
  },
});

publicApiClient.interceptors.response.use(
  (response) => response.data,
  (error) => Promise.reject(error)
);

const jsonToParams = (json) => {
  return new URLSearchParams(json).toString();
};

export const getPublicHoursReport = (params) => {
  const queryParams = jsonToParams(params) || "";
  return publicApiClient.get("/public_reports/hours?" + queryParams);
};
