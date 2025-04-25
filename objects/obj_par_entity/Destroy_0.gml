/// @description Remove self from entity mapping
ds_map_delete(obj_manager.entity_mapping, string(id));
server_send_update([7, string(id)], 4608);
