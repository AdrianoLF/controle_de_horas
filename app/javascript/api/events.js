import apiClient from "./index";

const jsonToParams = (json) => {
  return new URLSearchParams(json).toString();
};

export const getEvents = (params) => {
  const queryParams = jsonToParams(params) || "";
  return apiClient.get("/events?" + queryParams);
};

export const getEvent = (id) => apiClient.get(`/events/${id}`);
export const deleteEvent = (id) => apiClient.delete(`/events/${id}`);
export const createEvent = (body) => apiClient.post(`/events`, body);
export const editEvent = (id, body) => apiClient.patch(`/events/${id}`, body);
