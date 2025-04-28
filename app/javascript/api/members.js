import apiClient from "./index";

const jsonToParams = (json) => {
  return new URLSearchParams(json).toString();
};

export const getMembers = (params) => {
  const queryParams = jsonToParams(params) || "";
  return apiClient.get("/members?" + queryParams);
};

export const getMember = (id) => apiClient.get(`/members/${id}`);
export const deleteMember = (id) => apiClient.delete(`/members/${id}`);
export const createMember = (body) => apiClient.post(`/members`, body);
export const editMember = (id, body) => apiClient.patch(`/members/${id}`, body);
