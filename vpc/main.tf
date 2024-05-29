#vpc creation#
locals {
  route_table_name = "rt"
}


resource "aws_vpc" "vpc_name" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

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
      Name = each.key
      #format(
      #  "%s-%s",
      #  element(split("_", each.key), 0),  #var.public_subnet_name,
      #  element(split("_", each.key), 2)  
      #  # split 문자로 key를 자른 후, idx:2인 데이터를 사용
      #)
    },
    var.default_tag
  )
}

resource "aws_subnet" "nfw_subnets" {
  for_each          = var.nfw_subnet_data
  vpc_id            = aws_vpc.vpc_name.id
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["zone"]
  
  # 공인 IP 자동 할당 활성화
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = each.key
    },
    var.default_tag
  )
}

#create NGW#
resource "aws_nat_gateway" "nat_gateway1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id = aws_subnet.public_subnets["nat_sub_1a"].id

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
  subnet_id = aws_subnet.public_subnets["nat_sub_2c"].id

  tags = merge(
    {
      Name = format("%s-%s", var.nat_gw_name, "2")
    },
    var.default_tag
  )
  
  depends_on = [aws_internet_gateway.igw]
}

#network firewall route table#
resource "aws_route_table" "igw_rt" {
  vpc_id = aws_vpc.vpc_name.id
  
  route {
    cidr_block = var.public_subnet_data["nat_sub_1a"].cidr
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.inspection_vpc_anfw.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.nfw_subnets["nfw_sub_1a"].id], 0)
  }

  route {
    cidr_block = var.public_subnet_data["nat_sub_2c"].cidr
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.inspection_vpc_anfw.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.nfw_subnets["nfw_sub_1a"].id], 0)
  }
  
  route {
    cidr_block = var.public_subnet_data["pub_sub_1a"].cidr
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.inspection_vpc_anfw.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.nfw_subnets["nfw_sub_1a"].id], 0)
  }

  route {
    cidr_block = var.public_subnet_data["pub_sub_2c"].cidr
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.inspection_vpc_anfw.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.nfw_subnets["nfw_sub_1a"].id], 0)
  }

  tags = merge(
    {
      Name = format("%s-%s", "igw", local.route_table_name)
    },
    var.default_tag
  )
}


resource "aws_route_table" "nfw_rt" {
  vpc_id = aws_vpc.vpc_name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      Name = format("%s-%s", "nfw", local.route_table_name)
    },
    var.default_tag
  )
}


resource "aws_route_table" "to_nfw_rt_a" {
  #count = 2
  vpc_id = aws_vpc.vpc_name.id
  
  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.inspection_vpc_anfw.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.nfw_subnets["nfw_sub_1a"].id], 0)
    #vpc_endpoint_id = aws_networkfirewall_firewall.inspection_vpc_anfw.firewall_status[0].sync_states[0].attachment[0].endpoint_id
  }

  tags = merge(
    {
      Name = format("%s-%s-%s", "public", local.route_table_name, "a")#count.index)
    },
    var.default_tag
  )
}

resource "aws_route_table" "to_nfw_rt_c" {
  vpc_id = aws_vpc.vpc_name.id
  
  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.inspection_vpc_anfw.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.nfw_subnets["nfw_sub_2c"].id], 0)
  }

  tags = merge(
    {
      Name = format("%s-%s-%s", "public", local.route_table_name, "c")#count.index)
    },
    var.default_tag
  )
}

#subnet과 연결
resource "aws_route_table_association" "nfw" {
  for_each       = var.nfw_subnet_data
  #subnet_id      = aws_subnet.public[each.key].id
  subnet_id      = aws_subnet.nfw_subnets[each.key].id
  route_table_id = aws_route_table.nfw_rt.id
}

# public 서브넷은 nfw endpoint로 전송
resource "aws_route_table_association" "public_a" {
  for_each       = toset(["pub_sub_1a", "nat_sub_1a"]) 
  #subnet_id      = aws_subnet.public[each.key].id
  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.to_nfw_rt_a.id
}

resource "aws_route_table_association" "public_c" {
  for_each       = toset(["pub_sub_2c", "nat_sub_2c"]) 
  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.to_nfw_rt_c.id
}

#igw의 edge association
resource "aws_route_table_association" "igw" {
  gateway_id = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.igw_rt.id
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
resource "aws_route_table" "private_rt_a" {
  vpc_id = aws_vpc.vpc_name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway1.id
  }

  tags = merge(
    {
      Name = format("%s-%s",var.private_rt_name, "a")
    },
    var.default_tag
  )
}

resource "aws_route_table" "private_rt_c" {
  vpc_id = aws_vpc.vpc_name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway2.id
  }

  tags = merge(
    {
      Name = format("%s-%s",var.private_rt_name, "c")
    },
    var.default_tag
  )
}

#Was만 NAT로의 경로 설정
# private route association
resource "aws_route_table_association" "private_a" {
  #for_each       = var.private_subnet_data
  #subnet_id      = aws_subnet.private_subnets[each.key].id
  subnet_id      = aws_subnet.private_subnets["app_sub_1a"].id
  route_table_id = aws_route_table.private_rt_a.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_subnets["app_sub_2c"].id
  route_table_id = aws_route_table.private_rt_c.id
}

#기본 private subnet
resource "aws_route_table" "private_rt_default" {
  vpc_id = aws_vpc.vpc_name.id

  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }

  tags = merge(
    {
      Name = format("%s-%s",var.private_rt_name, "c")
    },
    var.default_tag
  )
}

resource "aws_route_table_association" "private_default" {
  for_each       = toset(["web_sub_1a", "web_sub_2c","db_sub_1a", "db_sub_2c"])
  subnet_id      = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.private_rt_a.id
}