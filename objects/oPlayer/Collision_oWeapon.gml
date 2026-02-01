// other = oGun pickup (el objeto en el suelo)

// 0) Validaciones iniciales
if (other.no_pickup_timer > 0) exit;
if (global.ONLINE && other.taken) exit;

// ====== DIFERENCIAR SI ES LA MISMA ARMA ======
var same_weapon = (guns[weapon.index] != noone)
                && is_struct(other.weapon)
                && (string(guns[weapon.index].type2) == string(other.weapon.type2));

// ====== 1) STACK (Si es la misma arma, solo recargar balas) ======
if (same_weapon)
{
    if (guns[weapon.index].ammo > 0) exit; // Si aún tienes balas, no la recoges

    guns[weapon.index].ammo = min(guns[weapon.index].ammo + other.weapon.ammo, guns[weapon.index].maxAmmo);

    if (global.ONLINE)
    {
        if (oBrain.AmIPseudoHost)
        {
            var uid = other.net_uid;
            scr_release_spawn_point(other.x, other.y);
            instance_destroy(other);
            if (instance_exists(oOtherPlayer)) SendEventToClient(oOtherPlayer.clientId, "weapon_pickup_taken", { uid: uid });
        }
        else
        {
            other.taken = true;
            SendEventToClient(oOtherPlayer.clientId, "request_pickup_weapon", { uid: other.net_uid, mode: "stack" });
        }
    }
    else
    {
        instance_destroy(other);
    }
    exit;
}

// ====== 2) SWAP (Si es arma diferente, cambiar y borrar la vieja) ======

if (global.ONLINE)
{
    if (!oBrain.AmIPseudoHost)
    {
        // --- CLIENTE ---
        guns[weapon.index] = other.weapon; // Equipar local instantáneo
        other.taken = true;

        // Pedimos al host que destruya el pickup. 
        // NO mandamos datos de drop porque queremos que desaparezca.
        SendEventToClient(oOtherPlayer.clientId, "request_pickup_weapon", {
            uid: other.net_uid,
            mode: "swap"
        });
        
        instance_destroy(other); // Destrucción visual inmediata en cliente
    }
    else
    {
        // --- HOST ---
        var uid2 = other.net_uid;
        
        // 1. Simplemente sobreescribimos el arma (la vieja desaparece)
        guns[weapon.index] = other.weapon; 
        
        // 2. Liberamos el punto de spawn
        scr_release_spawn_point(other.x, other.y);
        
        // 3. Destruimos el pickup del suelo
        instance_destroy(other);
        
        // 4. Avisamos al cliente
        if (instance_exists(oOtherPlayer)) {
            SendEventToClient(oOtherPlayer.clientId, "weapon_pickup_taken", { uid: uid2 });
        }
    }
}
else
{
    // --- MODO OFFLINE ---
    guns[weapon.index] = other.weapon;
    instance_destroy(other);
}