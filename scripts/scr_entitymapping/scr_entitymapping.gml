// Map server objects to client objects.
global.entity_mapping = ds_map_create();
ds_map_add(global.entity_mapping, "obj_player", obj_c_player);
ds_map_add(global.entity_mapping, "obj_firepit", obj_c_firepit);
ds_map_add(global.entity_mapping, "obj_itemstack", obj_c_itemstack);
ds_map_add(global.entity_mapping, "obj_oaktree", obj_c_oaktree);
ds_map_add(global.entity_mapping, "obj_woodencrate", obj_c_woodencrate);
ds_map_add(global.entity_mapping, "obj_sign", obj_c_sign);
ds_map_add(global.entity_mapping, "obj_oaksapling", obj_c_oaksapling);