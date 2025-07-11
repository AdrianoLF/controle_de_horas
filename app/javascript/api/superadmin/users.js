import apiClient from "./index";
import { jsonToParams } from "../utils";

export const getUsers = (params) => {
  const queryParams = jsonToParams(params) || "";
  return apiClient.get("/users?" + queryParams);
};

export const createUser = (body) => apiClient.post("/users", body);

export const editUser = (id, body) => apiClient.patch(`/users/${id}`, body);
