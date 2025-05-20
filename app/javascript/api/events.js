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

export const addMemberToEvent = (eventId, memberId) =>
  apiClient.post(`/event_assignments`, {
    event_id: eventId,
    member_id: memberId,
  });

export const removeMemberFromEvent = (eventId, memberId) =>
  apiClient.delete(`/event_assignments/destroy_relationship`, {
    params: {
      event_id: eventId,
      member_id: memberId,
    },
  });
