#vpc creation#



resource "aws_vpc" "vpc_name" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = merge(
    {
      Name = var.vpc_name
    },
    var.default_tag
  )
}

#IGW 생성
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_name.id

  tags = merge(
    {
      Name = var.igw_name
    },
    var.default_tag
  )
}


#elastic IP address
resource "aws_eip" "nat_eip1" {
  domain     = "vpc"

  # 재생성시, 생성이 완료된 후 삭제
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      Name = format("%s-%s", var.nat_eip_name, "1")
    },
    var.default_tag
  )
}

resource "aws_eip" "nat_eip2" {
  domain     = "vpc"

  # 재생성시, 생성이 완료된 후 삭제
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      Name = format("%s-%s", var.nat_eip_name, "2")
    },
    var.default_tag
  )
}


#public subnets
resource "aws_subnet" "public_subnets" {
  for_each          = var.public_subnet_data
  vpc_id            = aws_vpc.vpc_name.id
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["zone"]
  
  # 공인 IP 자동 할당 활성화
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = format(
        "%s-%s",
        var.public_subnet_name,
        element(split("_", each.key), 2)  
        # split 문자로 key를 자른 후, idx:2인 데이터를 사용
      )
    },
    var.default_tag
  )
}


#create NGW#
resource "aws_nat_gateway" "nat_gateway1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id = aws_subnet.public_subnets["pub_sub_1a"].id

  tags = merge(
    {
      Name = format("%s-%s", var.nat_gw_name, "1")
    },
    var.default_tag
  )
  
  # igw가 생성된 후에 생성
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gateway2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id = aws_subnet.public_subnets["pub_sub_2c"].id

  tags = merge(
    {
      Name = format("%s-%s", var.nat_gw_name, "2")
    },
    var.default_tag
  )
  
  # igw가 생성된 후에 생성
  depends_on = [aws_internet_gateway.igw]
}


#public route table#
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      Name = var.public_rt_name
    },
    var.default_tag
  )
}

#public subnet과 연결
resource "aws_route_table_association" "public" {
  for_each       = var.public_subnet_data
  #subnet_id      = aws_subnet.public[each.key].id
  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.public_rt.id
}


#private subnets
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnet_data
  vpc_id            = aws_vpc.vpc_name.id
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["zone"]

  tags = merge(
    {
      Name = format(
        "%s-%s-%s",
        element(split("_", each.key), 0),
        var.private_subnet_name,
        element(split("_", each.key), 2)  
        # split 문자로 key를 자른 후, idx:2인 데이터를 사용
      )
    },
    var.default_tag
  )
}

#private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway1.id
  }

  tags = merge(
    {
      Name = var.private_rt_name
    },
    var.default_tag
  )
}

# private route association
resource "aws_route_table_association" "private" {
  for_each       = var.private_subnet_data
  subnet_id      = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.private_rt.id
}


/*
#app subnets
resource "aws_subnet" "app-subnet-1" {
  vpc_id     = aws_vpc.vpc_name.id
  cidr_block = var.app-subnet1-cidr
  availability_zone = var.az_1

  tags = {
    Name = var.app-subnet1-name
  }
}

resource "aws_subnet" "app-subnet-2" {
  vpc_id     = aws_vpc.vpc_name.id
  cidr_block = var.app-subnet2-cidr
  availability_zone = var.az_2

  tags = {
    Name = var.app-subnet2-name
  }
}


#database subnets#
resource "aws_subnet" "db-subnet-1" {
  vpc_id     = aws_vpc.vpc_name.id
  cidr_block = var.db-subnet1-cidr
  availability_zone = var.az_1

  tags = {
    Name = var.db-subnet1-name
  }
}

resource "aws_subnet" "db-subnet-2" {
  vpc_id     = aws_vpc.vpc_name.id
  cidr_block = var.db-subnet2-cidr
  availability_zone = var.az_2

  tags = {
    Name = var.db-subnet2-name
  }
}

#database subnet group#

resource "aws_db_subnet_group" "database-subnet-group" {
  name       = var.db-subnet-grp-name
  subnet_ids = [aws_subnet.db-subnet-1.id, aws_subnet.db-subnet-2.id]

}


#public route table#

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_rt-name"
  }
}
resource "aws_route_table_association" "public_rt-association1" {
  subnet_id      = aws_subnet.public-subnet-a-1.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table_association" "public_rt-association2" {
  subnet_id      = aws_subnet.web-subnet-2.id
  route_table_id = aws_route_table.public_rt.id
}

#private route table#

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway1.id
  }

   tags = {
    Name = "private_rt-name"
  }
}

resource "aws_route_table_association" "private_rt-association1" {
  subnet_id      = aws_subnet.app-subnet-1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt-association2" {
  subnet_id      = aws_subnet.app-subnet-2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_subnet" "public-subnet-a1" {
  vpc_id     = aws_vpc.vpc_name.id
  cidr_block = var.web-subnet1-cidr
  availability_zone = var.az_1

  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = var.nat_eip_name + "2"
    },
    var.default_tag
  )
}

resource "aws_subnet" "web-subnet-2" {
  vpc_id     = aws_vpc.vpc_name.id
  cidr_block = var.web-subnet2-cidr
  availability_zone = var.az_2
  map_public_ip_on_launch = true

  tags = {
    Name = var.web-subnet2-name
  }
}

resource "aws_route_table_association" "public_rt_association1" {
  subnet_id      = aws_subnet.public_subnets[var.public_subnet_name +"_1a"].id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table_association" "public_rt_association2" {
  subnet_id      = aws_subnet.public_subnets[var.public_subnet_name +"_2c"].id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "private_rt-association1" {
  subnet_id      = aws_subnet.app-subnet-1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt-association2" {
  subnet_id      = aws_subnet.app-subnet-2.id
  route_table_id = aws_route_table.private_rt.id
}

# public route association
*/