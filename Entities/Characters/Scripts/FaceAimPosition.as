//set facing direction to aiming direction

void onInit(CMovement@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 3;
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob.hasTag("dead")) return;
	
	const bool facing = (blob.getAimPos().x <= blob.getPosition().x);
	blob.SetFacingLeft(facing);

	// face for all attachments

	if (blob.hasAttached())
	{
		AttachmentPoint@[] aps;
		if (blob.getAttachmentPoints(@aps))
		{
			for (uint i = 0; i < aps.length; i++)
			{
				AttachmentPoint@ ap = aps[i];
				if (ap.socket && ap.getOccupied() !is null)
				{
					ap.getOccupied().SetFacingLeft(facing);
				}
			}
		}
	}
}
