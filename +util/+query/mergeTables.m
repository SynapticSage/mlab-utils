

% merge megatable with cofiring table
result = outerjoin(TABLE, cofiringstats, "LeftKeys", "Hash", "RightKeys", "key");

